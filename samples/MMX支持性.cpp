/*
	�Ƿ�֧��MMX

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

	// ���ض�̬���ӿ�
	if ( !( hDLL = LoadLibrary( dll_file )  )  )
	{
		cout << "DLL����ʧ�ܣ�" << endl;
		return -1;
	}

	//  ��ȡ������ڵ�ַ
	if ( !(is_processor_MMX_enable = GetProcAddress( hDLL, "is_processor_MMX_enable" ) ) )
	{
		cout << "DLL�ڲ�������ڵ�ַ��ȡʧ�ܣ�" << endl;
		FreeLibrary( hDLL );
		return -1;
	}
	
	//  ʹ��VC++������෽ʽ���øö�̬���ӿ��ڲ�����
	__asm
	{
		call	is_processor_MMX_enable
		
		push	edi
		lea		edi, is_support_MMX	
		mov		[edi], eax
		pop		edi
	}

	// ��ʾ����ȡ����Ϣ
	if ( is_support_MMX )
	{
		cout << "���Ĵ�����֧��MMX��MultiMedia eXtensions����ý����չ������" << endl;
	}
	else
	{
		cout << "���Ĵ�������֧��MMX��MultiMedia eXtensions����ý����չ������" << endl;
	}

	// �ͷ�DLL
	FreeLibrary( hDLL );

	// �˳�����
	cout << endl << "����������ఴ���»س��Ϳ����˳���" << endl;
	cin.get();
	cin.get();
	return 0;
}