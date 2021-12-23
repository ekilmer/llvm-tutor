; RUN: opt --enable-new-pm=0 -load %shlibdir/RIV%shlibext -load %shlibdir/DuplicateBB%shlibext -legacy-duplicate-bb -S %s | FileCheck  %s
; RUN: opt -load-pass-plugin %shlibdir/RIV%shlibext -load-pass-plugin %shlibdir/DuplicateBB%shlibext -passes=duplicate-bb -S %s | FileCheck  %s

; No integer reachable values (only floats), hence the only BasicBlock in foo
; is *not* duplicated

@var = global float 1.25

define i32 @foo(float %in) {
  ret i32 1
}

; CHECK-LABEL: foo
; CHECK-NEXT:  ret i32 1
