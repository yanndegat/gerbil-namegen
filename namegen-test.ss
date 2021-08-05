(import :std/test
        :namegen/namegen)

(def namegen-test
  (test-suite "test :namegen"
    (test-case "print"
               (println (namegen '(s ("ith" ("'" C)) V)))
               (println (namegen '(B d v v " '" m "' " sw)))
               (println (namegen '(sw " " sw)))
               (println (namegen '(n  " " sw)))
               (println (namegen '(s C V "." s C V))))))

(unless (run-tests! namegen-test) (exit 1))
