;;;; System definition for maxpc-ext.

(defsystem "maxpc-ext"
  :description "Extensions for Max Rottenkolber's MaxPC parsing library."
  :author "Nicholas Hubbard <nicholashubbard@posteo.net>"
  :license "GNU Affero General Public License"
  :depends-on ("maxpc")
  :components ((:file "maxpc-ext")))
