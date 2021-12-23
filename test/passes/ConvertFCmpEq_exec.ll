; This should return 0 as `a == b` is going to be false for floating point numbers
; RUN: lli %S/../Inputs/FCmpEqInput.ll

; After the transformation, `a == b` is replaced with `a - b < eps`, which is
; going to be true for floating point numbers.
; RUN: opt --load-pass-plugin=%shlibdir/FindFCmpEq%shlibext \
; RUN:   --load-pass-plugin=%shlibdir/ConvertFCmpEq%shlibext \
; RUN:   --passes="convert-fcmp-eq" -S %S/../Inputs/FCmpEqInput.ll -o %t.bin
; RUN: not lli %t.bin
