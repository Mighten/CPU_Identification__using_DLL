/*
	是否支持MMX

	Oct 6th, 2014  21:10
		Signed-off-by:  Mighten Dai
*/

#include <iostream>
#include <windows.h>

using namespace std;

///////////////////////////////////////////////////////////
HINSTANCE	hDLL = NULL;
char		dll_file[] = "cpu_identity.dll";
void		*is_processor_MMX_enable = NULL;

///////////////////////////////////////////////////////////
int main( int argc, char *argv[] )
{
	DWORD	is_support_MMX = 0;

	// 加载动态链接库
	if ( !( hDLL = LoadLibrary( dll_file )  )  )
	{
		cout << "DLL加载失败！" << endl;
		return -1;
	}

	//  获取函数入口地址
	if ( !(is_processor_MMX_enable = GetProcAddress( hDLL, "is_processor_MMX_enable" ) ) )
	{
		cout << "DLL内部函数入口地址获取失败！" << endl;
		FreeLibrary( hDLL );
		return -1;
	}
	
	//  使用VC++内联汇编方式调用该动态链接库内部函数
	__asm
	{
		call	is_processor_MMX_enable
		
		push	edi
		lea		edi, is_support_MMX	
		mov		[edi], eax
		pop		edi
	}

	// 显示所获取的信息
	if ( is_support_MMX )
	{
		cout << "您的处理器支持MMX（MultiMedia eXtensions，多媒体拓展技术）" << endl;
	}
	else
	{
		cout << "您的处理器不支持MMX（MultiMedia eXtensions，多媒体拓展技术）" << endl;
	}

	// 释放DLL
	FreeLibrary( hDLL );

	// 退出程序
	cout << endl << "程序结束，多按几下回车就可以退出。" << endl;
	cin.get();
	cin.get();
	return 0;
}