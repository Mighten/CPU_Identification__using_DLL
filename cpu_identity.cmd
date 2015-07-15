;@echo off
;goto  make_dll_file_procedures
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;		Single Micro-processor's CPU identifying.
;
;		See the details how to build please Read the tail of this file.
;
;		Oct 04, 2014   17:10
;		Mar 22, 2015   01:35
;		Signed-off-by: Mighten Dai
;
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.386p
		.model flat, stdcall
		option casemap :none

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include			windows.inc
include			user32.inc
includelib		user32.lib
include			kernel32.inc
includelib		kernel32.lib

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data
szBuffer		db   512	dup(0)

szTitle						db			'Fatal Error!', 0
szErrorOverflow				db			'Error: Buffer Overflow!!!', 0

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;======================================================================================
;	proto-type:
;		int    get_processor_number(  );
;
;		__return:
;			Number of processor(stored in EAX)
get_processor_number		proc

	push		ecx
	
	push		ebp
	mov			ebp, esp
	sub			esp, 10h
	
	lea			eax, [ebp - 4]  ; lpSystemAffinityMask
	push		eax
	sub			eax, 4			; lpProcessAffinityMask
	push		eax
	call		GetCurrentProcess
	push		eax
	call		GetProcessAffinityMask
	
	xor			eax, eax
	mov			ecx, [ebp - 4]
	
	CPU_COUNTing:
	inc			eax
	shr			ecx, 1
	jcxz		return_with_CPU_NUM
	jmp			short CPU_COUNTing
	
	return_with_CPU_NUM:
	leave
	pop			ecx
	ret
	
get_processor_number		endp

;======================================================================================
;	proto-type:
;		int    get_processor_type_id(  );
;
;		__return:
;			TYPE ID of processor(stored in EAX)
;-----------------------------------------------------------------
; #define		Original_OEM_Processor						00B
; #define		Intel_OverDrive_Processor					01B
; #define		Dual_Processor__Not_applicated_to_486__		10B
; #define		Intel_Reserved								11B
;
get_processor_type_id		proc
		pushf
		push	ebx
		push	ecx
		push	edx
		
		mov		eax, 1
		dw		0a20fh		; CPUID
		
		; get the specific bits of processor type ID.
		shr		eax, 12
		and		eax, 11b

		pop		edx
		pop		ecx
		pop		ebx
		popf
		
		; mov	eax, eax
		ret
get_processor_type_id		endp

;======================================================================================
;	proto-type:
;		int    get_processor_family_id(  );
;
;		__return:
;			Family ID of processor(stored in EAX)
;
get_processor_family_id		proc
		pushf
		push	ebx
		push	ecx
		push	edx

		mov		eax, 1
		dw		0a20fh		; CPUID

		mov		ebx, eax

		; get family ID bits
		shr		eax, 8
		and		eax, 0fh

		; get extended family ID bits
		shr		ebx, 20
		and		ebx, 0FFH

		; The below rules are from Intel ... Manual 2A Instruction Set Reference
		.if		eax == 0fh
			add		eax, ebx
		.endif
		
		pop		edx
		pop		ecx
		pop		ebx
		popf
		
		; mov	eax, eax
		ret
get_processor_family_id		endp

;======================================================================================
;	proto-type:
;		int    get_processor_model_id(  );
;
;		__return:
;			Model ID of processor(stored in EAX)
;
get_processor_model_id		proc
		pushf
		push	ebx
		push	ecx
		push	edx
		
		mov		eax, 1
		dw		0a20fh		; CPUID

		mov		ecx, eax
		mov		ebx, eax

		; Get Model ID
		shr		ecx, 4
		and		ecx, 0fh

		; get family ID bits
		shr		eax, 8
		and		eax, 0fh

		; get extended family ID bits
		shr		ebx, 20
		and		ebx, 0FFH
		
		; The below rules are from Intel ... Manual 2A Instruction Set Reference
		.if		( eax == 06h || eax == 0fh )
			shl		ebx, 4
			add		ebx, ecx
			mov		eax, ebx
		.else
			mov		eax, ecx
		.endif
		
		pop		edx
		pop		ecx
		pop		ebx
		popf
		
		; mov	eax, eax
		ret

get_processor_model_id		endp

;======================================================================================
;	proto-type:
;		int    get_processor_brand_index(  );
;
;		__return:
;			Processor's brand index (stored in EAX)
;
get_processor_brand_index		proc
		pushf
		push	ebx
		push	ecx
		push	edx
		
		mov		eax, 1
		dw		0a20fh		; CPUID
		
		; get the specific bits of processor brand index.
		and		ebx, 0ffh
		mov		eax, ebx

		pop		edx
		pop		ecx
		pop		ebx
		popf

		ret
get_processor_brand_index		endp

;======================================================================================
;	proto-type:
;		int    get_processor_CLFLUSH_instruction_cache_line_size(  );
;
;		__return:
;			Processor's CLFLUSH instruction cache line size (stored in EAX)
;
get_processor_CLFLUSH_instruction_cache_line_size		proc
		pushf
		push	ebx
		push	ecx
		push	edx
		
		mov		eax, 1
		dw		0a20fh		; CPUID
		
		; get the specific bits of CLFLUSH instruction cache line size.
		shr		ebx, 8
		and		ebx, 0ffh
		mov		eax, ebx

		pop		edx
		pop		ecx
		pop		ebx
		popf

		ret
get_processor_CLFLUSH_instruction_cache_line_size		endp

;======================================================================================
;	proto-type:
;		int    get_processor_local_APIC_id(  );
;
;		__return:
;			Processor's Local APIC ID (stored in EAX)
;
get_processor_local_APIC_id		proc
		pushf
		push	ebx
		push	ecx
		push	edx
		
		mov		eax, 1
		dw		0a20fh		; CPUID
		
		; get the specific bits of processor's local APIC id.
		shr		ebx, 16
		and		ebx, 0ffh
		mov		eax, ebx

		pop		edx
		pop		ecx
		pop		ebx
		popf

		ret
get_processor_local_APIC_id		endp

;======================================================================================
;	proto-type:
;		int    is_processor_SSE3_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_SSE3_enable		proc
	pushf
	push	ebx
	push	ecx
	push	edx
	
	mov		eax, 1
	dw		0a20fh		; CPUID

	; the bit #0 in ecx Denote SSE3 is enable or not.
	mov		eax, ecx
	and		eax, 1
	
	pop		edx
	pop		ecx
	pop		ebx
	popf
	
	; mov		eax, eax
	ret

is_processor_SSE3_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_PCLMULQDQ_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_PCLMULQDQ_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	; the bit #1 in ecx Denote PCLMULQDQ is enable or not.
	mov		eax, ecx
	shr		eax, 1
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_PCLMULQDQ_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_DTES64_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_DTES64_enable		proc
	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	; the bit #2 in ecx Denote 64-bit DS Area is enable or not.
	mov		eax, ecx
	shr		eax, 2
	and		eax, 1
	
	pop		edx
	pop		ecx
	pop		ebx
	popf
	
	; mov		eax, eax
	ret

is_processor_DTES64_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_MONITOR_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_MONITOR_enable		proc
	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	; the bit #3 in ecx Denote MONITOR/MWAIT is enable or not.
	mov		eax, ecx
	shr		eax, 3
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf
	
	; mov		eax, eax
	ret

is_processor_MONITOR_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_DS_CPL_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_DS_CPL_enable		proc
	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	; the bit #4 in ecx Denote CPL Qualified Debug Store is enable or not.
	mov		eax, ecx
	shr		eax, 4
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf
	
	; mov		eax, eax
	ret

is_processor_DS_CPL_enable		endp


;======================================================================================
;	proto-type:
;		int    is_processor_VMX_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_VMX_enable		proc
	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	; the bit #5 in ecx Denote Virtual Machine Extensions is enable or not.
	mov		eax, ecx
	shr		eax, 5
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf
	
	; mov		eax, eax
	ret

is_processor_VMX_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_SMX_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_SMX_enable		proc
	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	; the bit #6 in ecx Denote Safer Mode Extensions is enable or not.
	mov		eax, ecx
	shr		eax, 6
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_SMX_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_EST_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_EST_enable		proc
	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	; the bit #7 in ecx Denote Enhanced Intel SpeedStep Technology is enable or not.
	mov		eax, ecx
	shr		eax, 7
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_EST_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_TM2_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_TM2_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	; the bit #8 in ecx Denote Thermal Monitor 2 is enable or not.
	mov		eax, ecx
	shr		eax, 8
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_TM2_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_SSSE3_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_SSSE3_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	; the bit #8 in ecx Denote SSSE3 is enable or not.
	mov		eax, ecx
	shr		eax, 9
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_SSSE3_enable		endp


;======================================================================================
;	proto-type:
;		int    is_processor_CNXT_ID_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_CNXT_ID_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, ecx
	shr		eax, 10
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_CNXT_ID_enable		endp


;======================================================================================
;	proto-type:
;		int    is_processor_FMA_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_FMA_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, ecx
	shr		eax, 12
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_FMA_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_CMPXCHG16B_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_CMPXCHG16B_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, ecx
	shr		eax, 13
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_CMPXCHG16B_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_xTPR_Update_Control_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_xTPR_Update_Control_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, ecx
	shr		eax, 14
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_xTPR_Update_Control_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_PDCM_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_PDCM_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, ecx
	shr		eax, 15
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_PDCM_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_PCID_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_PCID_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, ecx
	shr		eax, 17
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_PCID_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_DCA_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_DCA_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, ecx
	shr		eax, 18
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_DCA_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_SSE4_1_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_SSE4_1_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, ecx
	shr		eax, 19
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_SSE4_1_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_SSE4_2_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_SSE4_2_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, ecx
	shr		eax, 20
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_SSE4_2_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_x2APIC_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_x2APIC_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, ecx
	shr		eax, 21
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_x2APIC_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_MOVBE_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_MOVBE_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, ecx
	shr		eax, 22
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_MOVBE_enable		endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;======================================================================================
;	proto-type:
;		int    is_processor_POPCNT_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_POPCNT_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, ecx
	shr		eax, 23
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_POPCNT_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_TSC_Deadline_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_TSC_Deadline_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, ecx
	shr		eax, 24
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_TSC_Deadline_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_AESNI_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_AESNI_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, ecx
	shr		eax, 25
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_AESNI_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_XSAVE_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_XSAVE_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, ecx
	shr		eax, 26
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_XSAVE_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_OSXSAVE_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_OSXSAVE_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, ecx
	shr		eax, 27
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_OSXSAVE_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_AVX_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_AVX_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, ecx
	shr		eax, 28
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_AVX_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_F16C_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_F16C_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, ecx
	shr		eax, 29
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_F16C_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_RDRAND_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_RDRAND_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, ecx
	shr		eax, 30
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_RDRAND_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_x87_FPU_on_Chip_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_x87_FPU_on_Chip_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, edx
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_x87_FPU_on_Chip_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_?_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_VME_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, edx
	shr		eax, 1
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_VME_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_DE_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_DE_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, edx
	shr		eax, 2
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_DE_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_PSE_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_PSE_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, edx
	shr		eax, 3
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_PSE_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_TSC_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_TSC_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, edx
	shr		eax, 4
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_TSC_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_MSR_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_MSR_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, edx
	shr		eax, 5
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_MSR_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_PAE_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_PAE_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, edx
	shr		eax, 6
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_PAE_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_MCE_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_MCE_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, edx
	shr		eax, 7
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_MCE_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_CX8_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_CX8_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, edx
	shr		eax, 8
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_CX8_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_APIC_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_APIC_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, edx
	shr		eax, 9
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_APIC_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_SEP_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_SEP_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, edx
	shr		eax, 11
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_SEP_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_MTRR_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_MTRR_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, edx
	shr		eax, 12
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_MTRR_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_PGE_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_PGE_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, edx
	shr		eax, 13
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_PGE_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_MCA_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_MCA_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, edx
	shr		eax, 14
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_MCA_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_CMOV_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_CMOV_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, edx
	shr		eax, 15
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_CMOV_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_PAT_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_PAT_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, edx
	shr		eax, 16
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_PAT_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_PSE_36_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_PSE_36_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, edx
	shr		eax, 17
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_PSE_36_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_PSN_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_PSN_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, edx
	shr		eax, 18
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_PSN_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_CLFSH_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_CLFSH_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, edx
	shr		eax, 19
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_CLFSH_enable		endp


;======================================================================================
;	proto-type:
;		int    is_processor_DS_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_DS_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, edx
	shr		eax, 21
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_DS_enable		endp


;======================================================================================
;	proto-type:
;		int    is_processor_ACPI_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_ACPI_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, edx
	shr		eax, 22
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_ACPI_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_MMX_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_MMX_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, edx
	shr		eax, 23
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_MMX_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_FXSR_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_FXSR_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, edx
	shr		eax, 24
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_FXSR_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_SSE_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_SSE_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, edx
	shr		eax, 25
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_SSE_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_SSE2_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_SSE2_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, edx
	shr		eax, 26
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_SSE2_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_SS_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_SS_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, edx
	shr		eax, 27
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_SS_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_HTT_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_HTT_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, edx
	shr		eax, 28
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_HTT_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_TM_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_TM_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, edx
	shr		eax, 29
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_TM_enable		endp

;======================================================================================
;	proto-type:
;		int    is_processor_PBE_enable(  );
;
;		__return:
;			1 ---support (stored in EAX)
;			0 ---don't support
is_processor_PBE_enable		proc

	pushf
	push	ebx
	push	ecx
	push	edx

	mov		eax, 1
	dw		0a20fh		; CPUID

	mov		eax, edx
	shr		eax, 31
	and		eax, 1

	pop		edx
	pop		ecx
	pop		ebx
	popf

	; mov		eax, eax
	ret

is_processor_PBE_enable		endp

;======================================================================================
;	proto-type:
;		int    get_processor_vendor_id( char *_pointer, unsigned int _length_of_bytes );
;
;	NOTE: Never abort executing while parameter _pointer is NULL.
;
;		__Parameters:
;			_pointer			point to the buffer.
;			_length_of_bytes	Buffer length.
;
;		__return:
;			Works well  --- return 0    (stored in EAX), and 4-byte vendor value is in the memory pointed by _pointer.
;			Otherwise, return the desired size of buffer.
;
get_processor_vendor_id			proc    _pointer, _length_of_bytes
		pushf
		push	edi
		push	ebx
		push	ecx
		push	edx

		mov		eax, _length_of_bytes
		
		.if ( eax < 4 * 4  )
			invoke		MessageBox, NULL, offset szErrorOverflow, offset szTitle, ( MB_OK or MB_ICONHAND )
			mov			eax, 4 * 4 
			jmp			__vendor_id_getting_overflow_abort
		.endif

		mov		eax, 1
		dw		0a20fh		; CPUID

		; Set destination.
		mov		edi, _pointer
		cld
		
		; EAX --> dword ptr [ edi ]
		stosd
		
		; EBX --> dword ptr [ edi ]
		mov		eax, ebx
		stosd
		
		; ECX --> dword ptr [ edi ]
		mov		eax, ecx
		stosd
		
		; EDX --> dword ptr [ edi ]
		mov		eax, edx
		stosd

		;    (EAX) = 0, denotes this function works well.
		xor		eax, eax
		
		__vendor_id_getting_overflow_abort:
		pop		edx
		pop		ecx
		pop		ebx
		pop		edi

		popf
		ret
get_processor_vendor_id			endp

;======================================================================================
;	proto-type:
;		int    get_processor_whole_name( char *_pointer, unsigned int _length_of_bytes );
;
;	NOTE: Never abort executing while parameter _pointer is NULL.
;
;		__Parameters:
;			_pointer			point to the buffer.
;			_length_of_bytes	Buffer length.
;
;		__return:
;			Works well  --- return 0    (stored in EAX)
;			Otherwise, return the desired size of buffer.
;
get_processor_whole_name		proc    _pointer, _length_of_bytes

		pushf
		pushad
		
		mov		eax, _length_of_bytes
		
		; On Overflow, Clean environment.
		.if  eax < ( 4 * 4 * 3 + 1 )
			invoke		MessageBox, NULL, offset szErrorOverflow, offset szTitle, ( MB_OK or MB_ICONHAND )
			popad
			popf
			mov		eax, ( 4 * 4 * 3 + 1 )
			ret
		.endif

		mov		edi, _pointer
		
		cld
		mov		ecx, 3
		mov		eax, 80000002h
		
		_reading:
			push	eax
			push	ecx
			dw		0a20fh			; CPUID  Machine code: 0F A2

			stosd
			mov		eax, ebx
			stosd
			mov		eax, ecx
			stosd
			mov		eax, edx
			stosd

			pop		ecx
			pop		eax

			inc		eax

		loop	_reading

		
		dec		edi
		mov		byte ptr [ edi ], 0  ; NULL
		

		popad
		popf

		xor		eax, eax		
		ret

get_processor_whole_name		endp

;======================================================================================
DllEntry			proc	_hInstance, _dwReason, _dwReserved

		mov		eax, TRUE
		ret

DllEntry			endp

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end		DllEntry

;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::		
:make_dll_file_procedures
set target=cpu_identity
\masm32\bin\rc copyright.rc
\masm32\bin\ml /nologo /c /coff %target%.cmd
\masm32\bin\link /nologo /subsystem:windows /Def:%target%.def %target%.obj copyright.res
del /q *.obj
del /q %target%.lib
del /q *.exp
move %target%.dll ..