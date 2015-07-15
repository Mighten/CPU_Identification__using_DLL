/*
	Multi-Thread run on multi-core/multi-CPU  by using SetThreadAffinity.

	Get All the Vendor ID of CPU you have.

	 Demonstration

	Mighten Dai, 15:48, Mar 21, 2015 
*/

#define		THREAD_PARAM_IN
#define		THREAD_PARAM_OUT

/////////////////////////////////////////////////////////////////////////////////////////
#include <windows.h>
#include <iostream>

using namespace std;

typedef		DWORD		(__stdcall *NONE_PARAM_FUNCTION)();
typedef		DWORD		(__stdcall *TWO_PARAM_FUNCTION)(BYTE *, DWORD );

/////////////////////////////////////////////////////////////////////////////////////////
//   Define thread-function  Parameters.
struct PARAM
{
	// #1: The function used to point to the Function Address in DLL.
	THREAD_PARAM_IN		LPVOID		FunctionAddress;

	// #2: The number of parameter(s) --- that's to say the function's type.
	THREAD_PARAM_IN		DWORD		FunctionType; // parameter is 0, 1, 2

	// #3: The desired Affinity Mask ID, which has the ability to run the specific CPU Function.
	THREAD_PARAM_IN		DWORD		AffinityMaskID;

	// #4: Count   --- Specific the total number of Processors or Cores to be tested. 
	THREAD_PARAM_IN		BYTE		Number;

	// #5: Count   --- Specific the total number of Processors or Cores to be tested. 
	THREAD_PARAM_IN		BYTE		LeftNumber;
	
	// #6: Buffer
	THREAD_PARAM_OUT	BYTE		szBuffer[512];

};

/////////////////////////////////////////////////////////////////////////////////////////
// GLOBAL variable.
struct PARAM			thread_parameter;
DWORD					dwThreadID = 0;
HANDLE					hThread = NULL;
HANDLE					hEvent	= NULL;
HMODULE					hDLL = NULL;

NONE_PARAM_FUNCTION		get_processor_number 	= NULL;
TWO_PARAM_FUNCTION		get_processor_vendor_id	= NULL;

/////////////////////////////////////////////////////////////////////////////////////////
///       Functions'   Proto-type
VOID					InitEnvironment( VOID);
VOID					CleanEnvironment( VOID);
DWORD	__stdcall		ThreadProc( LPVOID  pParam );

/////////////////////////////////////////////////////////////////////////////////////////
//		InitEnvironment
//		--> Initialize the basic executing environment for Demo
//		Without parameters, without return value
//
//		Caution!!!!!!
//			This module require global variable, if you want to use this module later,
//				Keep it in mind that: synchronize the change with Global Variable
//				Or would cause some strange error
//
VOID					InitEnvironment( VOID )
{
	if ( !(hDLL = LoadLibrary("cpu_identity.dll") ) )
	{
		cout << "Fail to load DLL" << endl;
		cin.get();
		ExitProcess(-1);
	}

	get_processor_number = (NONE_PARAM_FUNCTION) GetProcAddress( hDLL, "get_processor_number");
	get_processor_vendor_id = ( TWO_PARAM_FUNCTION )GetProcAddress( hDLL, "get_processor_vendor_id");
	 
	if ( !get_processor_number || !get_processor_vendor_id )
	{
		printf("Fail to load Function\n");
		
		FreeLibrary( hDLL );
		cin.get();
		ExitProcess(-1);
	}

	thread_parameter.Number = get_processor_number();
	thread_parameter.LeftNumber = thread_parameter.Number;
	thread_parameter.FunctionType	= 2;

	hEvent = CreateEvent(	NULL,						// For Single-Process & multi-Thread is meaningless
							FALSE,						// It's desired to Reset the Event by Manual
							FALSE,						// The initial state is Signaled.
							NULL						// For Single-Process & multi-Thread is meaningless
						);

	if ( !hEvent )
	{
		printf( "[Main Thread][Abort]: Failure on executing CreateEvent, error code is 0x%.8X\n", GetLastError() );
		cin.get();
		ExitProcess(-1);
	}
	printf( "[Main Thread][Success]: CreateEvent OK, Handle= 0x%.8X\n", hEvent );

	hThread = CreateThread(	NULL,						// Security Attributes.
							0,							// Stack Size set by Default.
							ThreadProc,					// Thread run on this.
							(LPVOID)&thread_parameter,  // Thread parameter.
							0,							// Thread Flag.
							&dwThreadID);				// Storage for Thread ID.
	if ( !hThread )
	{
		printf( "[Main Thread][Abort]: Failure on executing CreateThread, error code is 0x%.8X\n", GetLastError() );
	//	CloseHandle(hEvent);	// It doesn't required, because it will be closed automatically.
		cin.get();
		ExitProcess(-1);
	}

	printf( "[Main Thread][Success]: CreateThread OK, TID = 0x%.8X, Handle= 0x%.8X\n\n\n", dwThreadID, hThread );

	// Now return to main without any returning value.
	return ;
}

/////////////////////////////////////////////////////////////////////////////////////////
//		CleanEnvironment
//		--> Clean the basic executing environment for Demo
//		Without parameters, without return value
//
//		Caution!!!!!!
//			This module require global variable, if you want to use this module later,
//				Keep it in mind that: synchronize the change with Global Variable
//				Or would cause some strange error
//
VOID					CleanEnvironment( VOID)
{
	FreeLibrary(hDLL);
	printf( "[Main Thread]: Terminate the child Thread returned %d\n", TerminateThread( hThread, 0 ) );
	//	CloseHandle(hEvent);	// It doesn't required, because it will be closed automatically.

	printf( "[Main Thread]: Nothing todo then, press key \"Enter\" to exit.\n" );
	return ;
}


/////////////////////////////////////////////////////////////////////////////////////////
//		ThreadProc
//		--> This is a New thread's Procedure.
//		[Parameter] type is struct PARAM, set by CreateThread
//		[Return]	0
//
DWORD	__stdcall ThreadProc( LPVOID  pParam )
{
	struct PARAM	*param = ( struct PARAM	*)pParam;

	while ( param->LeftNumber )
	{
		WaitForSingleObject(hEvent, INFINITE);  // It can be started at main()

		get_processor_vendor_id( thread_parameter.szBuffer, 512 );

		SetEvent(hEvent);
	}

	return 0;
}


/////////////////////////////////////////////////////////////////////////////////////////
DWORD  main( void )
{
	InitEnvironment();

	while ( thread_parameter.LeftNumber-- )
	{
		DWORD	*point = (DWORD *)&thread_parameter.szBuffer[0];

		DWORD  MaskID = 1;
		MaskID <<= thread_parameter.LeftNumber;

		cout << "Set Thread Affinity " << MaskID << ", its previous Affinity Mask ID=" << SetThreadAffinityMask( hThread, MaskID ) <<endl;

		SetEvent( hEvent );							// Enable thread executing.
		ResumeThread(hThread);
		Sleep(100);

		WaitForSingleObject( hEvent, INFINITE );	// Thread Has done once
		
		printf("[CPU %.2u] Vendor ID: %.8X-%.8X-%.8X-%.8X\n\n", thread_parameter.LeftNumber,
														point[0],
														point[1],
														point[2],
														point[3]  );
	}

	CleanEnvironment();

	cin.get();
	return 0;
}