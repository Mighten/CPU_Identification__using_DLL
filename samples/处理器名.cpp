/*
	处理器名

	Oct 6th, 2014  20:50
		Signed-off-by: Mighten Dai
*/

#include <iostream>
#include <windows.h>

using namespace std;

///////////////////////////////////////////////////////////
HINSTANCE	hDLL = NULL;
char		dll_file[] = "cpu_identity.dll";
void		*get_processor_whole_name = NULL;

///////////////////////////////////////////////////////////
int main( int argc, char *argv[] )
{
	char	szBuffer[ 4 * 4 * 4 + 1];

	// 加载动态链接库
	if ( !( hDLL = LoadLibrary( dll_file )  )  )
	{
		cout << "DLL加载失败！" << endl;
		return -1;
	}

	//  获取函数入口地址
	if ( !(get_processor_whole_name = GetProcAddress( hDLL, "get_processor_whole_name" ) ) )
	{
		cout << "DLL内部函数入口地址获取失败！" << endl;
		FreeLibrary( hDLL );
		return -1;
	}
	
	//  使用VC++内联汇编方式调用该动态链接库内部函数
	__asm
	{
		// 
		mov		eax, 4 * 4 * 4 + 1
		push	eax		//  将 4 * 4 * 4 + 1作第二个参数压栈
		lea		eax, szBuffer[0]
		push	eax		//	将 &szBuffer[0]作第一个参数压栈
		call	get_processor_whole_name
	}

	// 显示所获取的信息
	cout << "处理器名称： " << szBuffer << endl;

	// 释放DLL
	FreeLibrary( hDLL );

	// 退出程序
	cout << endl << "程序结束，多按几下回车就可以退出。" << endl;
	cin.get();
	cin.get();
	return 0;
}