(defsystem :infra
  :depends-on (:std :dat :cli :skel :log :net :packy)
  :components ((:file "bootstrap")
               (:file "deploy"))
  :build-pathname "infra")
