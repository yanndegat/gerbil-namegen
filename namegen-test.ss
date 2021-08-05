(import :std/test
        :namegen/namegen)

(def namegen-test
  (test-suite "test :namegen"
    (test-case "print"
               (println (namegen '(s ("ith" ("'" C)) V)))
               (println (namegen '(s C V " '" m "' " s ((C V) (V D)))))
               (println (namegen '(s C V "." s C V))))))


(unless (run-tests! namegen-test) (exit 1))
