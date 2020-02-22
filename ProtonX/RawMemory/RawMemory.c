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

Word pointerAsWord(void* pointer)
    {
    return(AsWord(pointer));
    }
    
Word pointerAsAddress(void* pointer)
    {
    return(AsWord(pointer));
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

void setWordAtAddress(Word word,Word address)
    {
    if (address != 0)
        {
        *AsUntaggedWordPointer(address) = word;
        }
    }

char* charPointerToIndexAtAddress(SlotIndex index,Word address)
    {
    return(AsCharPointer(AsWordPointer(address) + index.index));
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
    *(AsWordPointer(AsUntaggedAddress(address)) + index.index) = inputAddress;
    }

void setAddressAtAddress(Word inputAddress,Word address)
    {
    *(AsWordPointer(AsUntaggedAddress(address))) = inputAddress;
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

