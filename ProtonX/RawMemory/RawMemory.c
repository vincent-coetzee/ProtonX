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

//Word wordAtPointer(void* pointer)
//    {
//    return(*AsWordPointer(pointer));
//    }
//    
//void* pointerAtPointer(void* pointer)
//    {
//    return(AsPointer(*AsWordPointer(AsUntaggedPointer(pointer))));
//    }
//
//Word untaggedWordAtPointer(void* pointer)
//    {
//    return(AsUntaggedWord(*AsWordPointer(pointer)));
//    }
//    
//void setWordAtPointer(Word word,void* pointer)
//    {
//    *AsWordPointer(pointer) = word;
//    }
//    
//void setAddressAtPointer(Word word,void* pointer)
//    {
//    *AsWordPointer(pointer) = word;
//    }
//
//void setWordAtIndexAtPointer(Word word,SlotIndex index,void* pointer)
//    {
//    if (pointer)
//        {
//        *(AsWordPointer(pointer) + index.index) = word;
//        }
//    }
//    
//void setAddressAtIndexAtPointer(Word word,SlotIndex index,void* pointer)
//    {
//    if (pointer)
//        {
//        *(AsWordPointer(pointer) + index.index) = word;
//        }
//    }
//
//void setTaggedWordAtIndexAtPointer(Word word,SlotIndex index,void* pointer)
//    {
//    *(AsWordPointer(pointer) + index.index) = AsUntaggedWord(word);
//    }
//    
//void setInt64AtIndexAtPointer(long long value,SlotIndex index,void* pointer)
//    {
//    *(AsInt64Pointer(pointer) + index.index) = AsInt64(value);
//    }
//    
//Word wordAtIndexAtPointer(SlotIndex index,void* pointer)
//    {
////    printf("wordAtIndexAtPointer(%ld,%llX)\n",index.index,AsUntaggedWordPointer(pointer));
//    WordPointer wordPointer = AsUntaggedWordPointer(pointer);
//    if (wordPointer)
//        {
////        printf("Word Pointer after adding index = %llX\n",AsWordPointer(wordPointer) + index.index);
//        return(*(AsWordPointer(wordPointer) + index.index));
//        }
//    return(0);
//    }
//    
//Word untaggedWordAtIndexAtPointer(SlotIndex index,void* pointer)
//    {
//    return(AsUntaggedWord(*(AsUntaggedWordPointer(pointer) + index.index)));
//    }

Word pointerAsWord(void* pointer)
    {
    return(AsWord(pointer));
    }
    
Word pointerAsAddress(void* pointer)
    {
    return(AsWord(pointer));
    }
//
//void* wordAsPointer(Word word)
//    {
//    return(AsPointer(word));
//    }
//    
//void* untaggedWordAsPointer(Word word)
//    {
//    return(AsUntaggedPointer(word));
//    }

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
//    
//void* untaggedPointerAtAddress(Word address)
//    {
//    if (address == 0)
//        {
//        return(NULL);
//        }
//    return(*(AsUntaggedPointerPointer(address)));
//    }
//
//Word untaggedPointerAsAddress(void* pointer)
//    {
//    if (pointer == NULL)
//        {
//        return(0);
//        }
//    return((AsUntaggedWord(pointer)));
//    }

void setWordAtAddress(Word word,Word address)
    {
    if (address != 0)
        {
        *AsUntaggedWordPointer(address) = word;
        }
    }
//
//void setPointerAtIndexAtPointer(void* pointer,SlotIndex index,void* targetPointer)
//    {
//    if (targetPointer != NULL)
//        {
//        *(AsWordPointer(targetPointer) + index.index) = AsWord(pointer);
//        }
//    }
//
//void setObjectPointerAtIndexAtPointer(void* pointer,SlotIndex index,void* targetPointer)
//    {
//    if (targetPointer != NULL)
//        {
//        *(AsWordPointer(targetPointer) + index.index) = AsTaggedObject(pointer);
//        }
//    }
//
//void tagAndSetPointerAtIndexAtPointer(void* pointer,SlotIndex index,void* targetPointer)
//    {
//    if (targetPointer != NULL)
//        {
//        *(AsWordPointer(targetPointer) + index.index) = AsTaggedObject(pointer);
//        }
//    }
//
//void tagAndSetAddressAtIndexAtPointer(Word address,SlotIndex index,void* targetPointer)
//    {
//    if (targetPointer != NULL)
//        {
//        *(AsWordPointer(targetPointer) + index.index) = AsTaggedWord(address);
//        }
//    }
//
//void* pointerAtIndexAtPointer(SlotIndex index,void* pointer)
//    {
//    if (pointer == NULL)
//        {
//        return(NULL);
//        }
//    return(AsPointer(*(AsWordPointer(pointer) + index.index)));
//    }
//
//void* untaggedPointerAtIndexAtPointer(SlotIndex index,void* pointer)
//    {
//    if (pointer == NULL)
//        {
//        return(NULL);
//        }
//    return(AsUntaggedPointer(*(AsWordPointer(pointer) + index.index)));
//    }
//
//void* untaggedPointerToIndexAtPointer(SlotIndex index,void* pointer)
//    {
//    return(AsUntaggedPointer(AsWordPointer(pointer) + index.index));
//    }

char* charPointerToIndexAtAddress(SlotIndex index,Word address)
    {
    return(AsCharPointer(AsWordPointer(address) + index.index));
    }
    
//void* pointerToIndexAtPointer(SlotIndex index,void* pointer)
//    {
//    return(AsPointer(AsWordPointer(AsUntaggedPointer(pointer)) + index.index));
//    }
    
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
    
//Word taggedObject(void* pointer)
//    {
//    return(AsTaggedObject(pointer));
//    }
//
//Word taggedObjectAddress(Word pointer)
//    {
//    return(AsTaggedObject(pointer));
//    }

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
    return(AsTaggedAddress(address));
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

//PrivateFloat64 taggedFloat64(Word header,double value)
//    {
//    PrivateFloat64 theDouble = {header,value};
//    theDouble.header = AsTaggedFloat64(0);
//    theDouble.float64 = value;
//    return(theDouble);
//    }

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
    
//void* untaggedObject(void* pointer)
//    {
//    return(AsUntaggedObject(pointer));
//    }
    
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
//
//Word untaggedBitsAtIndexAtPointer(SlotIndex index,void* pointer)
//    {
//    return(AsUntaggedBits(*(AsWordPointer(pointer) + index.index)));
//    }
//
//void setTaggedBitsAtIndexAtPointer(Word bits,SlotIndex index,void* pointer)
//    {
//    *(AsWordPointer(pointer) + index.index) = AsTaggedBits(bits);
//    }
//
//Word untaggedAddressAtIndexAtPointer(SlotIndex index,void* pointer)
//    {
//    return(AsUntaggedWord(*(AsWordPointer(pointer) + index.index)));
//    }
//
//CInt64 untaggedIntegerAtIndexAtPointer(SlotIndex index,void* pointer)
//    {
//    return(AsUntaggedInteger(*(AsWordPointer(pointer) + index.index)));
//    }
//
//CUInt64 untaggedUIntegerAtIndexAtPointer(SlotIndex index,void* pointer)
//    {
//    return((CUInt64)AsUntaggedUInteger(*(AsWordPointer(pointer) + index.index)));
//    }
//
//float untaggedFloat32AtIndexAtPointer(SlotIndex index,void* pointer)
//    {
//    return(AsUntaggedFloat32(*(AsWordPointer(pointer) + index.index)));
//    }
//
//double untaggedFloat64AtIndexAtPointer(SlotIndex index,void* pointer)
//    {
//    return(AsUntaggedFloat64(*(AsWordPointer(pointer) + index.index)));
//    }
//
//_Bool untaggedBooleanAtIndexAtPointer(SlotIndex index,void* pointer)
//    {
//    return(AsUntaggedBoolean(*(AsWordPointer(pointer) + index.index)));
//    }
//
//Byte untaggedByteAtIndexAtPointer(SlotIndex index,void* pointer)
//    {
//    return(AsUntaggedByte(*(AsWordPointer(pointer) + index.index)));
//    }
//
//void setTaggedIntegerAtIndexAtPointer(CInt64 word,SlotIndex index,void* pointer)
//    {
//    *(AsWordPointer(pointer) + index.index) = AsTaggedInteger(word);
//    }
//
//void setTaggedUIntegerAtIndexAtPointer(CUInt64 word,SlotIndex index,void* pointer)
//    {
//    *(AsWordPointer(pointer) + index.index) = AsTaggedUInteger(word);
//    }
//
//void setTaggedByteAtIndexAtPointer(Byte word,SlotIndex index,void* pointer)
//    {
//    *(AsWordPointer(pointer) + index.index) = AsTaggedByte(word);
//    }
//
//void setTaggedBooleanAtIndexAtPointer(_Bool word,SlotIndex index,void* pointer)
//    {
//    *(AsWordPointer(pointer) + index.index) = AsTaggedBoolean(word);
//    }
//
//void setTaggedFloat32AtIndexAtPointer(float word,SlotIndex index,void* pointer)
//    {
//    *(AsWordPointer(pointer) + index.index) = AsTaggedFloat32(word);
//    }
    
//void setTaggedFloat64AtIndexAtPointer(double word,SlotIndex index,void* pointer)
//    {
//    *(AsWordPointer(pointer) + index.index) = AsTaggedFloat64(word);
//    }

//void setTaggedObjectAddressAtIndexAtPointer(Word address,SlotIndex index,void* pointer)
//    {
//    *(AsWordPointer(pointer) + index.index) = AsTaggedObject(address);
//    }
//
//void setTaggedObjectPointerAtIndexAtPointer(void* address,SlotIndex index,void* pointer)
//    {
//    *(AsWordPointer(pointer) + index.index) = AsTaggedObject(address);
//    }

Word bitWordAtIndexAtAddress(SlotIndex index,Word pointer)
    {
    Word offset = index.index * (sizeof(Word) + 1);
    BitsPointer bitsPointer = AsBitsPointer(pointer) + offset;
    Word word = 0;
    BitsPointer wordPointer = AsBitsPointer(&word);
    for (int loop = 0;loop < 7;loop++)
        {
        *wordPointer++ = *bitsPointer++;
        }
    bitsPointer++;
    *wordPointer = *bitsPointer;
    return(word);
    }
    
void setBitWordAtIndexAtAddress(Word word,SlotIndex index,Word pointer)
    {
    Word offset = index.index * (sizeof(Word) + 1);
    BitsPointer bitsPointer = AsBitsPointer(pointer) + offset;
    BitsPointer wordPointer = AsBitsPointer(&word);
    for (int loop = 0;loop<7;loop++)
        {
        *bitsPointer++ = *wordPointer++;
        }
    *bitsPointer++ = kTagBitsBits;
    *bitsPointer = *wordPointer;
    }
    
Word addressOfIndexAtPointer(SlotIndex index,void* pointer)
    {
    return(AsWord(AsWordPointer(pointer) + index.index));
    }
    
long long integerAtAddress(Word address)
    {
    return(AsUntaggedInteger(*AsUntaggedWordPointer(address)));
    }

Word addressAtAddress(Word address)
    {
    return(AsUntaggedAddress(*AsUntaggedWordPointer(address)));
    }

long long integerAtIndexAtAddress(SlotIndex index,Word address)
    {
    return(AsUntaggedInteger(*(AsUntaggedWordPointer(address) + index.index)));
    }

unsigned long long uintegerAtAddress(Word address)
    {
    return(AsUntaggedUInteger(*AsUntaggedWordPointer(address)));
    }

unsigned long long uintegerAtIndexAtAddress(SlotIndex index,Word address)
    {
    return(AsUntaggedUInteger(*(AsUntaggedWordPointer(address) + index.index)));
    }
    
_Bool booleanAtAddress(Word address)
    {
    return(AsUntaggedBoolean(*AsUntaggedWordPointer(address)));
    }

_Bool booleanAtIndexAtAddress(SlotIndex index,Word address)
    {
    return(AsUntaggedBoolean(*(AsUntaggedWordPointer(address) + index.index)));
    }
    
float float32AtAddress(Word address)
    {
    return(AsUntaggedFloat32(*AsUntaggedWordPointer(address)));
    }

float float32AtIndexAtAddress(SlotIndex index,Word address)
    {
    return(AsUntaggedFloat32(*(AsUntaggedWordPointer(address) + index.index)));
    }
    
Word bitsAtAddress(Word address)
    {
    return(AsUntaggedBits(*AsUntaggedWordPointer(address)));
    }

Word bitsAtIndexAtAddress(SlotIndex index,Word address)
    {
    return(AsUntaggedBits(*(AsUntaggedWordPointer(address) + index.index)));
    }

unsigned char byteAtAddress(Word address)
    {
    return(AsUntaggedByte(*AsUntaggedWordPointer(address)));
    }

unsigned char byteAtIndexAtAddress(SlotIndex index,Word address)
    {
    return(AsUntaggedByte(*(AsUntaggedWordPointer(address) + index.index)));
    }
//
// ADDRESS SETTING AND GETTING
//
Word addressAtIndexAtAddress(SlotIndex index,Word address)
    {
    return(AsUntaggedAddress(*(AsWordPointer(AsUntaggedAddress(address)) + index.index)));
    }

void setAddressAtIndexAtAddress(Word inputAddress,SlotIndex index,Word address)
    {
    *(AsWordPointer(AsUntaggedAddress(address)) + index.index) = AsTaggedAddress(inputAddress);
    }

void setAddressAtAddress(Word inputAddress,Word address)
    {
    *(AsWordPointer(AsUntaggedAddress(address))) = AsTaggedAddress(inputAddress);
    }

void setIntegerAtIndexAtAddress(long long integer,SlotIndex index,Word address)
    {
    *(AsWordPointer(AsUntaggedAddress(address)) + index.index) = AsTaggedInteger(integer);
    }
    
void setIntegerAtAddress(long long integer,Word address)
    {
    *AsWordPointer(AsUntaggedAddress(address)) = AsTaggedInteger(integer);
    }
    
void setFloat32AtAddress(float aFloat,Word address)
    {
    *AsWordPointer(AsUntaggedAddress(address)) = AsTaggedFloat32(aFloat);
    }
    
void setFloat32AtIndexAtAddress(float aFloat,SlotIndex index,Word address)
    {
    *(AsWordPointer(AsUntaggedAddress(address)) + index.index) = AsTaggedFloat32(aFloat);
    }

void setUIntegerAtIndexAtAddress(unsigned long long integer,SlotIndex index,Word address)
    {
    *(AsWordPointer(AsUntaggedAddress(address)) + index.index) = AsTaggedUInteger(integer);
    }
    
void setUIntegerAtAddress(unsigned long long integer,Word address)
    {
    *AsWordPointer(AsUntaggedAddress(address)) = AsTaggedUInteger(integer);
    }
    
void setBooleanAtIndexAtAddress(_Bool boolean,SlotIndex index,Word address)
    {
    *(AsWordPointer(AsUntaggedAddress(address)) + index.index) = AsTaggedBoolean(boolean);
    }
    
void setBooleanAtAddress(_Bool boolean,Word address)
    {
    *AsWordPointer(AsUntaggedAddress(address)) = AsTaggedBoolean(boolean);
    }
    
void setByteAtIndexAtAddress(unsigned char byte,SlotIndex index,Word address)
    {
    *(AsWordPointer(AsUntaggedAddress(address)) + index.index) = AsTaggedByte(byte);
    }
    
void setByteAtAddress(unsigned char byte,Word address)
    {
    *AsWordPointer(AsUntaggedAddress(address)) = AsTaggedByte(byte);
    }
    
void setBitsAtIndexAtAddress(Word bits,SlotIndex index,Word address)
    {
    *(AsWordPointer(AsUntaggedAddress(address)) + index.index) = AsTaggedBits(bits);
    }
    
void setBitsAtAddress(Word bits,Word address)
    {
    *AsWordPointer(AsUntaggedAddress(address)) = AsTaggedBits(bits);
    }
//
// TAGGING
//
//Word pointerAsTaggedObjectAddress(void* pointer)
//    {
//    return(AsTaggedObject(pointer));
//    }

