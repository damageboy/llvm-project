; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown | FileCheck %s

; This file tests following optimization
;
;        leal    (%rdx,%rax), %esi
;        subl    %esi, %ecx
;
; can be transformed to
;
;        subl    %edx, %ecx
;        subl    %eax, %ecx

; C - (A + B)   -->    C - A - B
define i32 @test1(i32* %p, i32 %a, i32 %b, i32 %c) {
; CHECK-LABEL: test1:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    # kill: def $edx killed $edx def $rdx
; CHECK-NEXT:    movl %esi, %eax
; CHECK-NEXT:    subl %edx, %ecx
; CHECK-NEXT:    subl %eax, %ecx
; CHECK-NEXT:    movl %ecx, (%rdi)
; CHECK-NEXT:    subl %edx, %eax
; CHECK-NEXT:    # kill: def $eax killed $eax killed $rax
; CHECK-NEXT:    retq
entry:
  %0 = add i32 %b, %a
  %sub = sub i32 %c, %0
  store i32 %sub, i32* %p, align 4
  %sub1 = sub i32 %a, %b
  ret i32 %sub1
}

; (A + B) + C   -->    C + A + B
define i32 @test2(i32* %p, i32 %a, i32 %b, i32 %c) {
; CHECK-LABEL: test2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    # kill: def $edx killed $edx def $rdx
; CHECK-NEXT:    movl %esi, %eax
; CHECK-NEXT:    addl %eax, %ecx
; CHECK-NEXT:    addl %edx, %ecx
; CHECK-NEXT:    movl %ecx, (%rdi)
; CHECK-NEXT:    subl %edx, %eax
; CHECK-NEXT:    # kill: def $eax killed $eax killed $rax
; CHECK-NEXT:    retq
entry:
  %0 = add i32 %a, %b
  %1 = add i32 %c, %0
  store i32 %1, i32* %p, align 4
  %sub1 = sub i32 %a, %b
  ret i32 %sub1
}

; C + (A + B)   -->    C + A + B
define i32 @test3(i32* %p, i32 %a, i32 %b, i32 %c) {
; CHECK-LABEL: test3:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    # kill: def $edx killed $edx def $rdx
; CHECK-NEXT:    movl %esi, %eax
; CHECK-NEXT:    addl %eax, %ecx
; CHECK-NEXT:    addl %edx, %ecx
; CHECK-NEXT:    movl %ecx, (%rdi)
; CHECK-NEXT:    subl %edx, %eax
; CHECK-NEXT:    # kill: def $eax killed $eax killed $rax
; CHECK-NEXT:    retq
entry:
  %0 = add i32 %a, %b
  %1 = add i32 %0, %c
  store i32 %1, i32* %p, align 4
  %sub1 = sub i32 %a, %b
  ret i32 %sub1
}

; (A + B) - C
; Can't be converted to A - C + B without introduce MOV
define i32 @test4(i32* %p, i32 %a, i32 %b, i32 %c) {
; CHECK-LABEL: test4:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    # kill: def $edx killed $edx def $rdx
; CHECK-NEXT:    movl %esi, %eax
; CHECK-NEXT:    leal (%rdx,%rax), %esi
; CHECK-NEXT:    subl %ecx, %esi
; CHECK-NEXT:    movl %esi, (%rdi)
; CHECK-NEXT:    subl %edx, %eax
; CHECK-NEXT:    # kill: def $eax killed $eax killed $rax
; CHECK-NEXT:    retq
entry:
  %0 = add i32 %b, %a
  %sub = sub i32 %0, %c
  store i32 %sub, i32* %p, align 4
  %sub1 = sub i32 %a, %b
  ret i32 %sub1
}

define i64 @test5(i64* %p, i64 %a, i64 %b, i64 %c) {
; CHECK-LABEL: test5:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movq (%rdi), %rax
; CHECK-NEXT:    subq %rdx, %rcx
; CHECK-NEXT:    subq %rax, %rcx
; CHECK-NEXT:    movq %rcx, (%rdi)
; CHECK-NEXT:    subq %rdx, %rax
; CHECK-NEXT:    retq
entry:
  %ld = load i64, i64* %p, align 8
  %0 = add i64 %b, %ld
  %sub = sub i64 %c, %0
  store i64 %sub, i64* %p, align 8
  %sub1 = sub i64 %ld, %b
  ret i64 %sub1
}

define i64 @test6(i64* %p, i64 %a, i64 %b, i64 %c) {
; CHECK-LABEL: test6:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movq (%rdi), %rax
; CHECK-NEXT:    addq %rdx, %rcx
; CHECK-NEXT:    addq %rax, %rcx
; CHECK-NEXT:    movq %rcx, (%rdi)
; CHECK-NEXT:    subq %rdx, %rax
; CHECK-NEXT:    retq
entry:
  %ld = load i64, i64* %p, align 8
  %0 = add i64 %b, %ld
  %1 = add i64 %0, %c
  store i64 %1, i64* %p, align 8
  %sub1 = sub i64 %ld, %b
  ret i64 %sub1
}

define i64 @test7(i64* %p, i64 %a, i64 %b, i64 %c) {
; CHECK-LABEL: test7:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movq (%rdi), %rax
; CHECK-NEXT:    addq %rdx, %rcx
; CHECK-NEXT:    addq %rax, %rcx
; CHECK-NEXT:    movq %rcx, (%rdi)
; CHECK-NEXT:    subq %rdx, %rax
; CHECK-NEXT:    retq
entry:
  %ld = load i64, i64* %p, align 8
  %0 = add i64 %b, %ld
  %1 = add i64 %c, %0
  store i64 %1, i64* %p, align 8
  %sub1 = sub i64 %ld, %b
  ret i64 %sub1
}

