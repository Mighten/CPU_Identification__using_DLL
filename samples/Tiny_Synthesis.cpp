/*
	���߳��µ�CPU��Ϣ��⡣
	
	ע�⣺������ֻ�ǿ��ļ���Ӧ�þ�����
			���������Ŀ��ļ������������65������û����һ���м�⣬ֻ�ǽ�����һ���֡�

	Oct 5th, 2014  09:19

		Signed-off-by:  Mighten Dai

*/
#include <windows.h>
#include <iostream>

using namespace std;

// DLL file name.
char		dll_name[] = "cpu_identity.dll";

// Handle of DLL file.
HMODULE		hDLL = NULL;

// System Information.
SYSTEM_INFO		SystemInfo;

// DLL function invoker.
typedef		int		(__stdcall *NONE_PARAM_FUNCTION)();
typedef		int		(__stdcall *TWO_PARAM_FUNCTION)(char *, unsigned int );
TWO_PARAM_FUNCTION		get_processor_vendor_id			= NULL;
TWO_PARAM_FUNCTION		get_processor_whole_name		= NULL;

NONE_PARAM_FUNCTION		is_processor_SSE3_enable		= NULL;
NONE_PARAM_FUNCTION		is_processor_PCLMULQDQ_enable	= NULL;
NONE_PARAM_FUNCTION		is_processor_DTES64_enable		= NULL;
NONE_PARAM_FUNCTION		is_processor_MONITOR_enable		= NULL;
NONE_PARAM_FUNCTION		is_processor_DS_CPL_enable		= NULL;
NONE_PARAM_FUNCTION		is_processor_VMX_enable			= NULL;
NONE_PARAM_FUNCTION		is_processor_SMX_enable			= NULL;
NONE_PARAM_FUNCTION		is_processor_EST_enable			= NULL;
NONE_PARAM_FUNCTION		is_processor_TM2_enable			= NULL;
NONE_PARAM_FUNCTION		is_processor_SSSE3_enable		= NULL;
NONE_PARAM_FUNCTION		is_processor_x87_FPU_on_Chip_enable = NULL;
NONE_PARAM_FUNCTION		is_processor_CMOV_enable		= NULL;
NONE_PARAM_FUNCTION		is_processor_MMX_enable			= NULL;
NONE_PARAM_FUNCTION		is_processor_SSE_enable			= NULL;
NONE_PARAM_FUNCTION		is_processor_SSE2_enable		= NULL;
NONE_PARAM_FUNCTION		is_processor_CNXT_ID_enable		= NULL;
NONE_PARAM_FUNCTION		is_processor_FMA_enable			= NULL;
NONE_PARAM_FUNCTION		is_processor_CMPXCHG16B_enable	= NULL;
NONE_PARAM_FUNCTION		is_processor_xTPR_Update_Control_enable	= NULL;



NONE_PARAM_FUNCTION		get_processor_family_id			= NULL;
NONE_PARAM_FUNCTION		get_processor_model_id			= NULL;
NONE_PARAM_FUNCTION		get_processor_type_id			= NULL;
NONE_PARAM_FUNCTION		get_processor_brand_index		= NULL;
NONE_PARAM_FUNCTION		get_processor_CLFLUSH_instruction_cache_line_size	= NULL;
NONE_PARAM_FUNCTION		get_processor_local_APIC_id		= NULL;


// Proto-type
int		initializer( void );
int		clean_environment( void);
int		__cdecl do_cpu_check( void );

/////////////////////////////////////////////////////////////////////////////////////////////
// Initialiting.
// Return :
//		-1:	failed.
//		 0:	success.
int		initializer( void )
{
	if (  ! ( hDLL = LoadLibrary( dll_name ) )   )
	{
		MessageBoxW( NULL, L"��̬���ӿ����ʧ�ܣ�", L"Fatal Error", 16 );
		return -1;
	}

	if(  ( is_processor_SSE3_enable	= GetProcAddress( hDLL, "is_processor_SSE3_enable" )  ) &&
	( is_processor_PCLMULQDQ_enable	= GetProcAddress( hDLL, "is_processor_PCLMULQDQ_enable" )   )&&
	( is_processor_DTES64_enable	= GetProcAddress( hDLL, "is_processor_DTES64_enable" )    )&&
	( is_processor_MONITOR_enable	= GetProcAddress( hDLL, "is_processor_MONITOR_enable" )   )&&
	( is_processor_DS_CPL_enable	= GetProcAddress( hDLL, "is_processor_DS_CPL_enable"))&&
	( is_processor_VMX_enable		= GetProcAddress( hDLL, "is_processor_VMX_enable" )  )&&
	( is_processor_SMX_enable		= GetProcAddress( hDLL, "is_processor_SMX_enable" )  )&&
	( is_processor_EST_enable		= GetProcAddress( hDLL, "is_processor_EST_enable")  )&&
	( is_processor_TM2_enable		= GetProcAddress( hDLL, "is_processor_TM2_enable")  )&&
	( is_processor_SSSE3_enable		= GetProcAddress( hDLL, "is_processor_SSSE3_enable")  )&&

	( get_processor_family_id		= GetProcAddress( hDLL, "get_processor_family_id")  )&&
	( get_processor_model_id		= GetProcAddress( hDLL, "get_processor_model_id")  )&&
	( get_processor_type_id			= GetProcAddress( hDLL, "get_processor_type_id")   )&&
	( get_processor_brand_index		= GetProcAddress( hDLL, "get_processor_brand_index")  )&&
	( get_processor_local_APIC_id	= GetProcAddress( hDLL, "get_processor_local_APIC_id") )&&
	( get_processor_CLFLUSH_instruction_cache_line_size = GetProcAddress( hDLL, "get_processor_CLFLUSH_instruction_cache_line_size") )&&
	( get_processor_vendor_id		= ( TWO_PARAM_FUNCTION )GetProcAddress( hDLL, "get_processor_vendor_id" ) )&&
	( get_processor_whole_name		= ( TWO_PARAM_FUNCTION )GetProcAddress( hDLL, "get_processor_whole_name") )&&
	( is_processor_SSE2_enable		= GetProcAddress( hDLL, "is_processor_SSE2_enable") )&&
	( is_processor_SSE_enable		= GetProcAddress( hDLL, "is_processor_SSE_enable") )&&
	( is_processor_MMX_enable		= GetProcAddress( hDLL, "is_processor_MMX_enable") )&&
	( is_processor_CMOV_enable		= GetProcAddress( hDLL, "is_processor_CMOV_enable") )&&
	( is_processor_x87_FPU_on_Chip_enable = GetProcAddress( hDLL, "is_processor_x87_FPU_on_Chip_enable") ) &&
	( is_processor_CNXT_ID_enable	= GetProcAddress( hDLL, "is_processor_CNXT_ID_enable") )&&
	( is_processor_FMA_enable		= GetProcAddress( hDLL, "is_processor_FMA_enable" ) ) &&
	( is_processor_CMPXCHG16B_enable= GetProcAddress( hDLL, "is_processor_CMPXCHG16B_enable") )&&
	( is_processor_xTPR_Update_Control_enable= GetProcAddress( hDLL, "is_processor_xTPR_Update_Control_enable") )

	
	)
	{
		return 0;
	}

	clean_environment();

	return -1;
}

/////////////////////////////////////////////////////////////////////////////////////////////
//  Release Resources.
//
int		clean_environment( void )
{
	FreeLibrary( hDLL );

	return 0;
}

/////////////////////////////////////////////////////////////////////////////////////////////
//  Doing CPU Check.
//
int		__cdecl do_cpu_check( void )
{
	char			vendor_ID[ 4 * 4 ];
	char			CPU_name[ 4 * 4 * 3 + 1 ];
	unsigned int	*p_vendor = (unsigned int *)vendor_ID;

	get_processor_whole_name( CPU_name, 4 * 4 * 3 + 1 );
	get_processor_vendor_id( vendor_ID, 4 * 4 );

	cout << "---------------------------------------------------------------" << endl;
	cout << "��ǰCPUȫ�ƣ�" << CPU_name << endl;
	printf("CPU���кţ�%.8X-%.8X-%.8X-%.8X\n\n", *(p_vendor), *(p_vendor + 1), *(p_vendor + 2), *(p_vendor + 3) ); 

	cout << "Family     ID = " << get_processor_family_id() << endl;

	printf( "Model      ID = %#x\n",  get_processor_model_id()      );
	printf( "Brand   Index = %#x\n",  get_processor_brand_index()   );
	printf( "Local APIC ID = %#x\n\n",  get_processor_local_APIC_id() );

	printf( "CLFLUSHָ�����д�С��%#x\n\n", get_processor_CLFLUSH_instruction_cache_line_size() );

	cout << "MMX ����֧��                     " << is_processor_MMX_enable()				<< "��֧�־���ʾ1����֧����ʾ0��" << endl;
	cout << "SSE ����֧��                     " << is_processor_SSE_enable()				<< "��֧�־���ʾ1����֧����ʾ0��" << endl;
	cout << "SSE2����֧��                     " << is_processor_SSE2_enable()				<< "��֧�־���ʾ1����֧����ʾ0��" << endl;
	cout << "SSE3����֧��                     " << is_processor_SSE3_enable()				<< "��֧�־���ʾ1����֧����ʾ0��" << endl;
	cout << "Supplemental SSE3                " << is_processor_SSSE3_enable()				<< "��֧�־���ʾ1����֧����ʾ0��" << endl;
	cout << "��������ָ��CMOV֧��             " << is_processor_CMOV_enable()				<< "��֧�־���ʾ1����֧����ʾ0��" << endl;
	cout << "PCLMULQDQָ��֧��                " << is_processor_PCLMULQDQ_enable()			<< "��֧�־���ʾ1����֧����ʾ0��" << endl;
	cout << "64-Bit DS Area                   " << is_processor_DTES64_enable()				<< "��֧�־���ʾ1����֧����ʾ0��" << endl;
	cout << "MONITOR/NWAIT����֧��            " << is_processor_MONITOR_enable()			<< "��֧�־���ʾ1����֧����ʾ0��" << endl;
	cout << "CPL Qualified Debug Store        " << is_processor_DS_CPL_enable()				<< "��֧�־���ʾ1����֧����ʾ0��" << endl;
	cout << "Virtual Machine Extensions       " << is_processor_VMX_enable()				<< "��֧�־���ʾ1����֧����ʾ0��" << endl;
	cout << "Safer Mode Extensions            " << is_processor_SMX_enable()				<< "��֧�־���ʾ1����֧����ʾ0��" << endl;
	cout << "Enhanced Intel SpeedStep(R) ���� " << is_processor_EST_enable()				<< "��֧�־���ʾ1����֧����ʾ0��" << endl;
	cout << "Ƭ��x86 FPU�������֧��          " << is_processor_x87_FPU_on_Chip_enable()	<< "��֧�־���ʾ1����֧����ʾ0��" << endl;
	cout << "Thermal Monitor 2                " << is_processor_TM2_enable()				<< "��֧�־���ʾ1����֧����ʾ0��" << endl;
	cout << "CNXT ID                          " << is_processor_CNXT_ID_enable()			<< "��֧�־���ʾ1����֧����ʾ0��" << endl;
	cout << "FMA                              " << is_processor_FMA_enable()				<< "��֧�־���ʾ1����֧����ʾ0��" << endl;
	cout << "CMPXCHG16B                       " << is_processor_CMPXCHG16B_enable()			<< "��֧�־���ʾ1����֧����ʾ0��" << endl;
	cout << "xTPR Update Control              " << is_processor_xTPR_Update_Control_enable()<< "��֧�־���ʾ1����֧����ʾ0��" << endl;
		
	cout << "---------------------------------------------------------------" << endl;

	return 0;
}

/////////////////////////////////////////////////////////////////////////////////////////////
int		__cdecl main( int argc, char *argv[] )
{
	GetSystemInfo( &SystemInfo );

	cout << "    The number of Processor = " << SystemInfo.dwNumberOfProcessors << endl;

	cout << "������Ĳ��ֹ��ܹ���֧��ö���� ����ʹ��cpu_identity.dll���ļ�������  " << endl;

	if (  initializer( ) )
	{
		cout << "��ʼ��ʧ�ܣ�����������У�" << endl;
		return -1;
	}

	// Check the part functions of processor.
	do_cpu_check( );
	
	clean_environment();

	// Paused, to exit, press Enter.
	cout << "���������һֱ���س��������˳�" << endl;
	cin.get();
	cin.get();

	return 0;
}