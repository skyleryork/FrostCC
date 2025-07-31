#include "f4se/PapyrusFormList.h"

#include "f4se/PapyrusVM.h"
#include "f4se/PapyrusNativeFunctions.h"

#include "f4se/GameObjects.h"
#include "f4se/GameRTTI.h"

namespace papyrusFormList
{

VMArray<SInt32> FindFormKeywords( BGSListForm *const thisFormList, VMArray<TESForm *> forms )
{
	VMArray<SInt32> indices;

	if ( thisFormList )
	{
		for ( UInt32 i = 0; i < forms.Length(); ++i )
		{
			SInt32 index = -1;
			TESForm *form;
			forms.Get( &form, i );

			BGSKeywordForm *const pKeywords = DYNAMIC_CAST( form, TESForm, BGSKeywordForm );
			if ( pKeywords )
			{
				for ( UInt32 j = 0; ( index < 0 ) && ( j < pKeywords->numKeywords ); ++j )
				{
					for ( UInt32 k = 0; k < thisFormList->forms.count; ++k )
					{
						BGSKeyword *const keywordForm = DYNAMIC_CAST( thisFormList->forms.entries[k], TESForm, BGSKeyword );
						if ( keywordForm && ( keywordForm == pKeywords->keywords[j] ) )
						{
							index = k;
							break;
						}
					}
				}
			}

			indices.Push( &index );
		}
	}

	return indices;
}

}

void papyrusFormList::RegisterFuncs( VirtualMachine *vm )
{
	vm->RegisterFunction( new NativeFunction1<BGSListForm, VMArray<SInt32>, VMArray<TESForm *>>( "FindFormKeywords", "FormList", papyrusFormList::FindFormKeywords, vm ) );
}
