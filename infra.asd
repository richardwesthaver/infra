(defsystem :infra
  :depends-on (:std :dat :cli :skel :log :net :packy :pod :box :organ)
  :components ((:file "autogen")
               (:file "deploy"))
  :build-pathname ".stash/bin/infra")
