; RUN: opt --enable-new-pm=0 -load %shlibdir/RIV%shlibext -load %shlibdir/DuplicateBB%shlibext -legacy-duplicate-bb -S %s | FileCheck  %s
; RUN: opt -load-pass-plugin %shlibdir/RIV%shlibext -load-pass-plugin %shlibdir/DuplicateBB%shlibext -passes=duplicate-bb -S %s | FileCheck  %s

; No local integer reachable values (only 1 global), hence the only BasicBlock
; in foo is *not* duplicated

@var = global i32 123

define i32 @foo() {
  ret i32 1
}

; CHECK-LABEL: foo
; CHECK-NEXT: ret i32 1
