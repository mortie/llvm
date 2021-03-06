; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=avx | FileCheck %s

%structTy = type { i8, i32, i32 }

@e = common global %structTy zeroinitializer, align 4

;; Ensure that MergeConsecutiveStores doesn't incorrectly reorder
;; store operations.  The first test stores in increasing address
;; order, the second in decreasing -- but in both cases should have
;; the same result in memory in the end.

define void @redundant_stores_merging() {
; CHECK-LABEL: redundant_stores_merging:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movabsq $1958505086977, %rax # imm = 0x1C800000001
; CHECK-NEXT:    movq %rax, e+{{.*}}(%rip)
; CHECK-NEXT:    retq
  store i32 1, i32* getelementptr inbounds (%structTy, %structTy* @e, i64 0, i32 1), align 4
  store i32 123, i32* getelementptr inbounds (%structTy, %structTy* @e, i64 0, i32 2), align 4
  store i32 456, i32* getelementptr inbounds (%structTy, %structTy* @e, i64 0, i32 2), align 4
  ret void
}

;; This variant tests PR25154.
define void @redundant_stores_merging_reverse() {
; CHECK-LABEL: redundant_stores_merging_reverse:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movabsq $1958505086977, %rax # imm = 0x1C800000001
; CHECK-NEXT:    movq %rax, e+{{.*}}(%rip)
; CHECK-NEXT:    retq
  store i32 123, i32* getelementptr inbounds (%structTy, %structTy* @e, i64 0, i32 2), align 4
  store i32 456, i32* getelementptr inbounds (%structTy, %structTy* @e, i64 0, i32 2), align 4
  store i32 1, i32* getelementptr inbounds (%structTy, %structTy* @e, i64 0, i32 1), align 4
  ret void
}

@b = common global [8 x i8] zeroinitializer, align 2

;; The 2-byte store to offset 3 overlaps the 2-byte store to offset 2;
;; these must not be reordered in MergeConsecutiveStores such that the
;; store to 3 comes first (e.g. by merging the stores to 0 and 2 into
;; a movl, after the store to 3).

define void @overlapping_stores_merging() {
; CHECK-LABEL: overlapping_stores_merging:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl $1, {{.*}}(%rip)
; CHECK-NEXT:    movw $2, b+{{.*}}(%rip)
; CHECK-NEXT:    retq
  store i16 0, i16* bitcast (i8* getelementptr inbounds ([8 x i8], [8 x i8]* @b, i64 0, i64 2) to i16*), align 2
  store i16 2, i16* bitcast (i8* getelementptr inbounds ([8 x i8], [8 x i8]* @b, i64 0, i64 3) to i16*), align 1
  store i16 1, i16* bitcast (i8* getelementptr inbounds ([8 x i8], [8 x i8]* @b, i64 0, i64 0) to i16*), align 2
  ret void
}

define void @extract_vector_store_16_consecutive_bytes(<2 x i64> %v, i8* %ptr) #0 {
; CHECK-LABEL: extract_vector_store_16_consecutive_bytes:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vmovups %xmm0, (%rdi)
; CHECK-NEXT:    retq
  %bc = bitcast <2 x i64> %v to <16 x i8>
  %ext00 = extractelement <16 x i8> %bc, i32 0
  %ext01 = extractelement <16 x i8> %bc, i32 1
  %ext02 = extractelement <16 x i8> %bc, i32 2
  %ext03 = extractelement <16 x i8> %bc, i32 3
  %ext04 = extractelement <16 x i8> %bc, i32 4
  %ext05 = extractelement <16 x i8> %bc, i32 5
  %ext06 = extractelement <16 x i8> %bc, i32 6
  %ext07 = extractelement <16 x i8> %bc, i32 7
  %ext08 = extractelement <16 x i8> %bc, i32 8
  %ext09 = extractelement <16 x i8> %bc, i32 9
  %ext10 = extractelement <16 x i8> %bc, i32 10
  %ext11 = extractelement <16 x i8> %bc, i32 11
  %ext12 = extractelement <16 x i8> %bc, i32 12
  %ext13 = extractelement <16 x i8> %bc, i32 13
  %ext14 = extractelement <16 x i8> %bc, i32 14
  %ext15 = extractelement <16 x i8> %bc, i32 15
  %gep00 = getelementptr inbounds i8, i8* %ptr, i64 0
  %gep01 = getelementptr inbounds i8, i8* %ptr, i64 1
  %gep02 = getelementptr inbounds i8, i8* %ptr, i64 2
  %gep03 = getelementptr inbounds i8, i8* %ptr, i64 3
  %gep04 = getelementptr inbounds i8, i8* %ptr, i64 4
  %gep05 = getelementptr inbounds i8, i8* %ptr, i64 5
  %gep06 = getelementptr inbounds i8, i8* %ptr, i64 6
  %gep07 = getelementptr inbounds i8, i8* %ptr, i64 7
  %gep08 = getelementptr inbounds i8, i8* %ptr, i64 8
  %gep09 = getelementptr inbounds i8, i8* %ptr, i64 9
  %gep10 = getelementptr inbounds i8, i8* %ptr, i64 10
  %gep11 = getelementptr inbounds i8, i8* %ptr, i64 11
  %gep12 = getelementptr inbounds i8, i8* %ptr, i64 12
  %gep13 = getelementptr inbounds i8, i8* %ptr, i64 13
  %gep14 = getelementptr inbounds i8, i8* %ptr, i64 14
  %gep15 = getelementptr inbounds i8, i8* %ptr, i64 15
  store i8 %ext00, i8* %gep00, align 1
  store i8 %ext01, i8* %gep01, align 1
  store i8 %ext02, i8* %gep02, align 1
  store i8 %ext03, i8* %gep03, align 1
  store i8 %ext04, i8* %gep04, align 1
  store i8 %ext05, i8* %gep05, align 1
  store i8 %ext06, i8* %gep06, align 1
  store i8 %ext07, i8* %gep07, align 1
  store i8 %ext08, i8* %gep08, align 1
  store i8 %ext09, i8* %gep09, align 1
  store i8 %ext10, i8* %gep10, align 1
  store i8 %ext11, i8* %gep11, align 1
  store i8 %ext12, i8* %gep12, align 1
  store i8 %ext13, i8* %gep13, align 1
  store i8 %ext14, i8* %gep14, align 1
  store i8 %ext15, i8* %gep15, align 1
  ret void
}

; PR34217 - https://bugs.llvm.org/show_bug.cgi?id=34217

define void @extract_vector_store_32_consecutive_bytes(<4 x i64> %v, i8* %ptr) #0 {
; CHECK-LABEL: extract_vector_store_32_consecutive_bytes:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vmovups %ymm0, (%rdi)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
  %bc = bitcast <4 x i64> %v to <32 x i8>
  %ext00 = extractelement <32 x i8> %bc, i32 0
  %ext01 = extractelement <32 x i8> %bc, i32 1
  %ext02 = extractelement <32 x i8> %bc, i32 2
  %ext03 = extractelement <32 x i8> %bc, i32 3
  %ext04 = extractelement <32 x i8> %bc, i32 4
  %ext05 = extractelement <32 x i8> %bc, i32 5
  %ext06 = extractelement <32 x i8> %bc, i32 6
  %ext07 = extractelement <32 x i8> %bc, i32 7
  %ext08 = extractelement <32 x i8> %bc, i32 8
  %ext09 = extractelement <32 x i8> %bc, i32 9
  %ext10 = extractelement <32 x i8> %bc, i32 10
  %ext11 = extractelement <32 x i8> %bc, i32 11
  %ext12 = extractelement <32 x i8> %bc, i32 12
  %ext13 = extractelement <32 x i8> %bc, i32 13
  %ext14 = extractelement <32 x i8> %bc, i32 14
  %ext15 = extractelement <32 x i8> %bc, i32 15
  %ext16 = extractelement <32 x i8> %bc, i32 16
  %ext17 = extractelement <32 x i8> %bc, i32 17
  %ext18 = extractelement <32 x i8> %bc, i32 18
  %ext19 = extractelement <32 x i8> %bc, i32 19
  %ext20 = extractelement <32 x i8> %bc, i32 20
  %ext21 = extractelement <32 x i8> %bc, i32 21
  %ext22 = extractelement <32 x i8> %bc, i32 22
  %ext23 = extractelement <32 x i8> %bc, i32 23
  %ext24 = extractelement <32 x i8> %bc, i32 24
  %ext25 = extractelement <32 x i8> %bc, i32 25
  %ext26 = extractelement <32 x i8> %bc, i32 26
  %ext27 = extractelement <32 x i8> %bc, i32 27
  %ext28 = extractelement <32 x i8> %bc, i32 28
  %ext29 = extractelement <32 x i8> %bc, i32 29
  %ext30 = extractelement <32 x i8> %bc, i32 30
  %ext31 = extractelement <32 x i8> %bc, i32 31
  %gep00 = getelementptr inbounds i8, i8* %ptr, i64 0
  %gep01 = getelementptr inbounds i8, i8* %ptr, i64 1
  %gep02 = getelementptr inbounds i8, i8* %ptr, i64 2
  %gep03 = getelementptr inbounds i8, i8* %ptr, i64 3
  %gep04 = getelementptr inbounds i8, i8* %ptr, i64 4
  %gep05 = getelementptr inbounds i8, i8* %ptr, i64 5
  %gep06 = getelementptr inbounds i8, i8* %ptr, i64 6
  %gep07 = getelementptr inbounds i8, i8* %ptr, i64 7
  %gep08 = getelementptr inbounds i8, i8* %ptr, i64 8
  %gep09 = getelementptr inbounds i8, i8* %ptr, i64 9
  %gep10 = getelementptr inbounds i8, i8* %ptr, i64 10
  %gep11 = getelementptr inbounds i8, i8* %ptr, i64 11
  %gep12 = getelementptr inbounds i8, i8* %ptr, i64 12
  %gep13 = getelementptr inbounds i8, i8* %ptr, i64 13
  %gep14 = getelementptr inbounds i8, i8* %ptr, i64 14
  %gep15 = getelementptr inbounds i8, i8* %ptr, i64 15
  %gep16 = getelementptr inbounds i8, i8* %ptr, i64 16
  %gep17 = getelementptr inbounds i8, i8* %ptr, i64 17
  %gep18 = getelementptr inbounds i8, i8* %ptr, i64 18
  %gep19 = getelementptr inbounds i8, i8* %ptr, i64 19
  %gep20 = getelementptr inbounds i8, i8* %ptr, i64 20
  %gep21 = getelementptr inbounds i8, i8* %ptr, i64 21
  %gep22 = getelementptr inbounds i8, i8* %ptr, i64 22
  %gep23 = getelementptr inbounds i8, i8* %ptr, i64 23
  %gep24 = getelementptr inbounds i8, i8* %ptr, i64 24
  %gep25 = getelementptr inbounds i8, i8* %ptr, i64 25
  %gep26 = getelementptr inbounds i8, i8* %ptr, i64 26
  %gep27 = getelementptr inbounds i8, i8* %ptr, i64 27
  %gep28 = getelementptr inbounds i8, i8* %ptr, i64 28
  %gep29 = getelementptr inbounds i8, i8* %ptr, i64 29
  %gep30 = getelementptr inbounds i8, i8* %ptr, i64 30
  %gep31 = getelementptr inbounds i8, i8* %ptr, i64 31
  store i8 %ext00, i8* %gep00, align 1
  store i8 %ext01, i8* %gep01, align 1
  store i8 %ext02, i8* %gep02, align 1
  store i8 %ext03, i8* %gep03, align 1
  store i8 %ext04, i8* %gep04, align 1
  store i8 %ext05, i8* %gep05, align 1
  store i8 %ext06, i8* %gep06, align 1
  store i8 %ext07, i8* %gep07, align 1
  store i8 %ext08, i8* %gep08, align 1
  store i8 %ext09, i8* %gep09, align 1
  store i8 %ext10, i8* %gep10, align 1
  store i8 %ext11, i8* %gep11, align 1
  store i8 %ext12, i8* %gep12, align 1
  store i8 %ext13, i8* %gep13, align 1
  store i8 %ext14, i8* %gep14, align 1
  store i8 %ext15, i8* %gep15, align 1
  store i8 %ext16, i8* %gep16, align 1
  store i8 %ext17, i8* %gep17, align 1
  store i8 %ext18, i8* %gep18, align 1
  store i8 %ext19, i8* %gep19, align 1
  store i8 %ext20, i8* %gep20, align 1
  store i8 %ext21, i8* %gep21, align 1
  store i8 %ext22, i8* %gep22, align 1
  store i8 %ext23, i8* %gep23, align 1
  store i8 %ext24, i8* %gep24, align 1
  store i8 %ext25, i8* %gep25, align 1
  store i8 %ext26, i8* %gep26, align 1
  store i8 %ext27, i8* %gep27, align 1
  store i8 %ext28, i8* %gep28, align 1
  store i8 %ext29, i8* %gep29, align 1
  store i8 %ext30, i8* %gep30, align 1
  store i8 %ext31, i8* %gep31, align 1
  ret void
}

