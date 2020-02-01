//
//  RawMemory.c
//  argon
//
//  Created by Vincent Coetzee on 2018/09/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#include <stdio.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#import "RawMemory.h"

Word wordAtPointer(void* pointer)
    {
    return(*AsWordPointer(pointer));
    }
    
void* pointerAtPointer(void* pointer)
    {
    return(AsPointer(*AsWordPointer(AsUntaggedPointer(pointer))));
    }

Word untaggedWordAtPointer(void* pointer)
    {
    return(AsUntaggedWord(*AsWordPointer(pointer)));
    }
    
void setWordAtPointer(Word word,void* pointer)
    {
    *AsWordPointer(pointer) = word;
    }
    
void setAddressAtPointer(Word word,void* pointer)
    {
    *AsWordPointer(pointer) = word;
    }

void setWordAtIndexAtPointer(Word word,SlotIndex index,void* pointer)
    {
    if (pointer)
        {
        *(AsWordPointer(pointer) + index.index) = word;
        }
    }
    
void setAddressAtIndexAtPointer(Word word,SlotIndex index,void* pointer)
    {
    if (pointer)
        {
        *(AsWordPointer(pointer) + index.index) = word;
        }
    }

void setTaggedWordAtIndexAtPointer(Word word,SlotIndex index,void* pointer)
    {
    *(AsWordPointer(pointer) + index.index) = AsUntaggedWord(word);
    }
    
void setInt64AtIndexAtPointer(long long value,SlotIndex index,void* pointer)
    {
    *(AsInt64Pointer(pointer) + index.index) = AsInt64(value);
    }
    
Word wordAtIndexAtPointer(SlotIndex index,void* pointer)
    {
//    printf("wordAtIndexAtPointer(%ld,%llX)\n",index.index,AsUntaggedWordPointer(pointer));
    WordPointer wordPointer = AsUntaggedWordPointer(pointer);
    if (wordPointer)
        {
//        printf("Word Pointer after adding index = %llX\n",AsWordPointer(wordPointer) + index.index);
        return(*(AsWordPointer(wordPointer) + index.index));
        }
    return(0);
    }
    
Word untaggedWordAtIndexAtPointer(SlotIndex index,void* pointer)
    {
    return(AsUntaggedWord(*(AsUntaggedWordPointer(pointer) + index.index)));
    }

Word pointerAsWord(void* pointer)
    {
    return(AsWord(pointer));
    }
    
Word pointerAsAddress(void* pointer)
    {
    return(AsWord(pointer));
    }

void* wordAsPointer(Word word)
    {
    return(AsPointer(word));
    }
    
void* untaggedWordAsPointer(Word word)
    {
    return(AsUntaggedPointer(word));
    }

Word wordAtAddress(Word address)
    {
    if (address == 0)
        {
        return(0);
        }
    return(*AsUntaggedWordPointer(address));
    }
    
Word untaggedWordAtAddress(Word address)
    {
    return(AsUntaggedWord(*AsUntaggedWordPointer(address)));
    }

Word wordAtIndexAtAddress(SlotIndex index,Word pointer)
    {
    return(*(AsUntaggedWordPointer(pointer) + index.index));
    }
    
void setWordAtIndexAtAddress(Word word,SlotIndex index,Word address)
    {
    *(AsUntaggedWordPointer(address) + index.index) = word;
    }
    
void* untaggedPointerAtAddress(Word address)
    {
    if (address == 0)
        {
        return(NULL);
        }
    return(*(AsUntaggedPointerPointer(address)));
    }

Word untaggedPointerAsAddress(void* pointer)
    {
    if (pointer == NULL)
        {
        return(0);
        }
    return((AsUntaggedWord(pointer)));
    }

void setWordAtAddress(Word word,Word address)
    {
    if (address != 0)
        {
        *AsUntaggedWordPointer(address) = word;
        }
    }

void setPointerAtIndexAtPointer(void* pointer,SlotIndex index,void* targetPointer)
    {
    if (targetPointer != NULL)
        {
        *(AsWordPointer(targetPointer) + index.index) = AsWord(pointer);
        }
    }
    
void setObjectPointerAtIndexAtPointer(void* pointer,SlotIndex index,void* targetPointer)
    {
    if (targetPointer != NULL)
        {
        *(AsWordPointer(targetPointer) + index.index) = AsTaggedObject(pointer);
        }
    }

void tagAndSetPointerAtIndexAtPointer(void* pointer,SlotIndex index,void* targetPointer)
    {
    if (targetPointer != NULL)
        {
        *(AsWordPointer(targetPointer) + index.index) = AsTaggedObject(pointer);
        }
    }
    
void tagAndSetAddressAtIndexAtPointer(Word address,SlotIndex index,void* targetPointer)
    {
    if (targetPointer != NULL)
        {
        *(AsWordPointer(targetPointer) + index.index) = AsTaggedWord(address);
        }
    }

void* pointerAtIndexAtPointer(SlotIndex index,void* pointer)
    {
    if (pointer == NULL)
        {
        return(NULL);
        }
    return(AsPointer(*(AsWordPointer(pointer) + index.index)));
    }

void* untaggedPointerAtIndexAtPointer(SlotIndex index,void* pointer)
    {
    if (pointer == NULL)
        {
        return(NULL);
        }
    return(AsUntaggedPointer(*(AsWordPointer(pointer) + index.index)));
    }
    
void* untaggedPointerToIndexAtPointer(SlotIndex index,void* pointer)
    {
    return(AsUntaggedPointer(AsWordPointer(pointer) + index.index));
    }

char* charPointerToIndexAtPointer(SlotIndex index,void* pointer)
    {
    return(AsCharPointer(AsWordPointer(pointer) + index.index));
    }
    
void* pointerToIndexAtPointer(SlotIndex index,void* pointer)
    {
    return(AsPointer(AsWordPointer(AsUntaggedPointer(pointer)) + index.index));
    }
    
Word taggedBoolean(_Bool word)
    {
    return(AsTaggedBoolean(word));
    }
    
Word taggedByte(unsigned char byte)
    {
    return(AsTaggedByte(byte));
    }
    
Word taggedDouble(float value)
    {
    return(AsTaggedFloat32(0));
    }
    
Word taggedObject(void* pointer)
    {
    return(AsTaggedObject(pointer));
    }
    
Word taggedObjectAddress(Word pointer)
    {
    return(AsTaggedObject(pointer));
    }

Word taggedInteger(CInt64 word)
    {
    return(AsTaggedInteger(word));
    }
    
Word taggedUInteger(CUInt64 word)
    {
    return(AsTaggedUInteger(word));
    }
    
Word taggedAddress(Word address)
    {
    return(AsTaggedWord(address));
    }
    
Word taggedFloat32(float value)
    {
    return(AsTaggedFloat32(value));
    }
    
Word taggedBits(Word bits)
    {
    return(AsTaggedBits(bits));
    }
    
double untaggedFloat64(PrivateFloat64 words)
    {
    return(words.float64);
    }

PrivateFloat64 taggedFloat64(Word header,double value)
    {
    PrivateFloat64 theDouble = {header,value};
    theDouble.header = AsTaggedFloat64(0);
    theDouble.float64 = value;
    return(theDouble);
    }

Word untaggedWord(Word word)
    {
    return(AsUntaggedWord(word));
    }
    
void* untaggedPointer(void* pointer)
    {
    return(AsUntaggedPointer(pointer));
    }
    
void* untaggedAddressAsPointer(Word address)
    {
    return(AsUntaggedPointer(address));
    }
    
_Bool untaggedBoolean(_Bool word)
    {
    return(AsUntaggedBoolean(word));
    }
    
CInt64 untaggedInteger(CInt64 word)
    {
    return(AsUntaggedUInteger(word));
    }
    
CUInt64 untaggedUInteger(CUInt64 word)
    {
    return(AsUntaggedInteger(word));
    }
    
unsigned char untaggedByte(unsigned char byte)
    {
    return(AsUntaggedByte(byte));
    }
    
void* untaggedObject(void* pointer)
    {
    return(AsUntaggedObject(pointer));
    }
    
float untaggedFloat32(float value)
    {
    return(AsUntaggedFloat32(value));
    }
    
Word untaggedAddress(Word value)
    {
    return(AsUntaggedWord(value));
    }
    
Word untaggedBits(Word value)
    {
    return(AsUntaggedBits(value));
    }

Word untaggedBitsAtIndexAtPointer(SlotIndex index,void* pointer)
    {
    return(AsUntaggedBits(*(AsWordPointer(pointer) + index.index)));
    }
    
void setTaggedBitsAtIndexAtPointer(Word bits,SlotIndex index,void* pointer)
    {
    *(AsWordPointer(pointer) + index.index) = AsTaggedBits(bits);
    }

Word untaggedAddressAtIndexAtPointer(SlotIndex index,void* pointer)
    {
    return(AsUntaggedWord(*(AsWordPointer(pointer) + index.index)));
    }
    
CInt64 untaggedIntegerAtIndexAtPointer(SlotIndex index,void* pointer)
    {
    return(AsUntaggedInteger(*(AsWordPointer(pointer) + index.index)));
    }
    
CUInt64 untaggedUIntegerAtIndexAtPointer(SlotIndex index,void* pointer)
    {
    return((CUInt64)AsUntaggedUInteger(*(AsWordPointer(pointer) + index.index)));
    }
    
float untaggedFloat32AtIndexAtPointer(SlotIndex index,void* pointer)
    {
    return(AsUntaggedFloat32(*(AsWordPointer(pointer) + index.index)));
    }
    
double untaggedFloat64AtIndexAtPointer(SlotIndex index,void* pointer)
    {
    return(AsUntaggedFloat64(*(AsWordPointer(pointer) + index.index)));
    }

_Bool untaggedBooleanAtIndexAtPointer(SlotIndex index,void* pointer)
    {
    return(AsUntaggedBoolean(*(AsWordPointer(pointer) + index.index)));
    }
    
Byte untaggedByteAtIndexAtPointer(SlotIndex index,void* pointer)
    {
    return(AsUntaggedByte(*(AsWordPointer(pointer) + index.index)));
    }

void setTaggedIntegerAtIndexAtPointer(CInt64 word,SlotIndex index,void* pointer)
    {
    *(AsWordPointer(pointer) + index.index) = AsTaggedInteger(word);
    }
    
void setTaggedUIntegerAtIndexAtPointer(CUInt64 word,SlotIndex index,void* pointer)
    {
    *(AsWordPointer(pointer) + index.index) = AsTaggedUInteger(word);
    }
    
void setTaggedByteAtIndexAtPointer(Byte word,SlotIndex index,void* pointer)
    {
    *(AsWordPointer(pointer) + index.index) = AsTaggedByte(word);
    }
    
void setTaggedBooleanAtIndexAtPointer(_Bool word,SlotIndex index,void* pointer)
    {
    *(AsWordPointer(pointer) + index.index) = AsTaggedBoolean(word);
    }
    
void setTaggedFloat32AtIndexAtPointer(float word,SlotIndex index,void* pointer)
    {
    *(AsWordPointer(pointer) + index.index) = AsTaggedFloat32(word);
    }
    
void setTaggedFloat64AtIndexAtPointer(double word,SlotIndex index,void* pointer)
    {
    *(AsWordPointer(pointer) + index.index) = AsTaggedFloat64(word);
    }

void setTaggedObjectAddressAtIndexAtPointer(Word address,SlotIndex index,void* pointer)
    {
    *(AsWordPointer(pointer) + index.index) = AsTaggedObject(address);
    }

void setTaggedObjectPointerAtIndexAtPointer(void* address,SlotIndex index,void* pointer)
    {
    *(AsWordPointer(pointer) + index.index) = AsTaggedObject(address);
    }


