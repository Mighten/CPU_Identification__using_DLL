####################################################
#
#		Makefile
#
#		Demonstration for CPUID 0
#
#		Oct 4th, 2014   20:12
#			Signed-off-by:   Mighten Dai
####################################################
DLL			=		cpu_identity
ML_FLAG		=		/c /coff
LINK_FLAG	=		/subsystem:windows /Dll


$(DLL).dll: $(DLL).obj $(DLL).def
	link	$(LINK_FLAG) /Def:$(DLL).def $(DLL).obj

.asm.obj:
	ml		$(ML_FLAG) $<

clean:
	del /q *.obj
	del /q $(DLL).lib
	del /q *.exp