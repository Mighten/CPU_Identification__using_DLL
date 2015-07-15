/*
	��������

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

	// ���ض�̬���ӿ�
	if ( !( hDLL = LoadLibrary( dll_file )  )  )
	{
		cout << "DLL����ʧ�ܣ�" << endl;
		return -1;
	}

	//  ��ȡ������ڵ�ַ
	if ( !(get_processor_whole_name = GetProcAddress( hDLL, "get_processor_whole_name" ) ) )
	{
		cout << "DLL�ڲ�������ڵ�ַ��ȡʧ�ܣ�" << endl;
		FreeLibrary( hDLL );
		return -1;
	}
	
	//  ʹ��VC++������෽ʽ���øö�̬���ӿ��ڲ�����
	__asm
	{
		// 
		mov		eax, 4 * 4 * 4 + 1
		push	eax		//  �� 4 * 4 * 4 + 1���ڶ�������ѹջ
		lea		eax, szBuffer[0]
		push	eax		//	�� &szBuffer[0]����һ������ѹջ
		call	get_processor_whole_name
	}

	// ��ʾ����ȡ����Ϣ
	cout << "���������ƣ� " << szBuffer << endl;

	// �ͷ�DLL
	FreeLibrary( hDLL );

	// �˳�����
	cout << endl << "����������ఴ���»س��Ϳ����˳���" << endl;
	cin.get();
	cin.get();
	return 0;
}