# vc-remote.nu
export-env {
  $env.VC_URL = "https://vc.compiler.company"
  $env.VC_ENDPOINT = $env.VC_URL + "/api/v4/"
  $env.VC = [[comp]; [packy]]
}

export def vc-call [
  ...args: string
  --path: string
  --query: string
] {
  http get -H [Authorization $"Bearer ($env.GITLAB_TOKEN)"] $"($env.VC_ENDPOINT)($path)($args|str join)?($query)"
}

# Search files on your GitLab server
export def vc-query-file [
  --file: string # file (or path to file if in a subfolder) you want to scan
  --phrase: string # phrase you want to search for
  --branch: string # branch to scan
] {
  let page_size = 100
  let projects = $"($env.VC_URL)/api/v4/projects/"
    # /projects endpoint can return up to $page_size items which is why we need multiple calls to retrieve full list
  let num_of_pages = ((vc-call --path "projects/" --query 'page=1&per_page=1&order_by=id&simple=true'|get id.0|into int) / $page_size|math round)
  seq 1 $num_of_pages|par-each {|page|
    vc-call "projects/" --query $"page=($page)&per_page=($page_size)"|select name id
  }
  |flatten
  |par-each {|repo|
    let payload = (vc-call $repo.id '/repository/files/' $file --query $"ref=($branch)")
    if ($payload|columns|find message|is-empty) {
      $payload
      |get content
      |decode base64
      |lines
      |find $phrase
      |if ($in|length) > 0 {
          echo $"($file) in ($repo.name) repo contains ($phrase) phrase"
        }
    }
  }
}

export def vc-projects [
  --group: string
] {
  if $group != null {
    vc-call "projects/" --query $"group=($group)"
  } else {
    vc-call "projects/"
  }
}

export def vc-update [] {
  if ('.git/' | path exists) == true {
    git pull origin HEAD
  } else if ('.hg/' | path exists) == true {
    hg pull -u
  } else { error make {msg: $"directory $(pwd) not tracked by VC"} }
}

export def vc-update* [] {
  ls | where type == dir | par-each { |it|
    cd $it.name; vc-update
  }
}

export def vc-mirror-update [] {
  git fetch upstream
  git pull upstream HEAD
  git push origin
}

export def vc-mirror-update* [] {
  ls | where type == dir | par-each { |it|
    if ($"($it.name)/.git" | path exists) == true {
      cd $it.name; vc-mirror-update
    }
  }
}
