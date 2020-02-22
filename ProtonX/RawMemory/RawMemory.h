//
//  RawMemory.h
//  argon
//
//  Created by Vincent Coetzee on 2018/09/25.
//  Copyright © 2018 Vincent Coetzee. All rights reserved.
//

#ifndef RawMemory_h
#define RawMemory_h

typedef unsigned long long Word;
typedef struct _DoubleWord
    {
    Word header;
    Word value;
    }
    DoubleWord;

typedef void* Pointer;
typedef Word* WordPointer;
typedef unsigned long HalfWord;
typedef unsigned char Byte;
typedef Byte* BytePointer;
typedef char* CharPointer;
typedef long long CInt64;
typedef unsigned long long CUInt64;
typedef unsigned char* BitsPointer;

typedef struct _SlotIndex
    {
    long index;
    }
    SlotIndex;
    
typedef struct _SlotOffset
    {
    long offset;
    }
    SlotOffset;

#define kWordSize (sizeof(Word))

#define kHeaderIndex (0)
#define kTypeIndex (1)

#define kStringSizeInBytesIndex (2)
#define kStringAllocatedSizeInBytesIndex (3)
#define kStringBytesIndex (4)
#define kStringBaseSize (5*kWordSize)

#define kInstanceSlotCountIndex (2)
#define kInstanceSlotsIndex (3)

#define kTypeNameIndex (3)
#define kTypeParentCountIndex (4)
#define kTypeSubTypeCountIndex (5)
#define kTypeSubTypeOffsetIndex (6)
#define kTypeParentsIndex (7)
#define kTypeBaseSize (8*kWordSize)

typedef struct _Root
    {
    Word threadId;  // which thread the root belongs to
    Word type;      // contains the type, stack or register
    Word offset;    // contains either the offset into the stack or the register number
    Word value;     // contains the word that must be replaced once it's changed
    }
    Root;
    
//
// ROOT FLAGS FOR USE IN GC
//
#define kRootTypeStack              ((Word)1)
#define kRootTypeRegister           ((Word)2)
//
// SEGMENT TYPES AND CONSTANTS
//
#define kSegmentNil                 ((Word)0)
#define kSegmentCode                ((Word)1)
#define kSegmentData                ((Word)2)
#define kSegmentStatic              ((Word)3)
#define kSegmentStack               ((Word)4)
#define kSegmentManaged             ((Word)5)

#define kNumberOfSegments          ((Word)6)
//
// INSTANCE FLAG
//
//#define kInstanceFlag               ((Word)1)
//#define kInstanceFlagMask           (((Word)1) << ((Word)63))
//#define kInstanceFlagShift          ((Word)63)
//
// TAG FLAGS FOR THE HEADER WORD
//

#define kTagBitsUInteger          ((Word)0)
#define kTagBitsInteger           ((Word)1)
#define kTagBitsFloat32           ((Word)2)
#define kTagBitsFloat64           ((Word)3)
#define kTagBitsBoolean           ((Word)4)
#define kTagBitsCharacter         ((Word)5)
#define kTagBitsByte              ((Word)6)
#define kTagBitsString            ((Word)7)
#define kTagBitsAddress           ((Word)8)
#define kTagBitsBits              ((Word)9)
#define kTagBitsPersistent        ((Word)10)


#define kTagBitsMask               ((Word)15)
#define kTagBitsShift              ((Word)59)

#define kHeaderMarkerMask             ((Word)1)
#define kHeaderMarkerShift            ((Word)58)
#define kHeaderMarkerMaskShifted      (((Word)1) << ((Word)58))

//
// WORD MACROS
//
#define AlignWordTo(w,a) ((((Word)(w)) + (((Word)(a)) - 1)) & (~((Word)(a - 1))))
#define AsPointerPointer(w) ((void**)(w))
#define AsInteger(w) ((CInt64)(w))
#define AsUInteger(w) ((CUInt64)(w))
#define AsFloat32(w) ((float)(w))
#define AsFloat64(w) ((double)(w))
#define AsCharacter(w) ((char)(w))
#define AsByte(w) ((Byte)(w))
#define AsBoolean(w) ((_Bool)(w))
#define AsWord(p) ((Word)(p))
#define AsAddress(p) ((Word)(p))
#define AsInt64(v) ((CInt64)(v))
#define AsBits(w) ((CUInt64)(w))
#define AsPointer(p) ((void*)(p))
#define AsPointerPointer(w) ((void**)(w))
#define AsCharPointer(p) ((char*)(p))
#define AsWordPointer(p) ((WordPointer)(p))
#define AsBytePointer(p) ((BytePointer)(p))
#define AsCharPointer(p) ((CharPointer)(p))
#define AsInt64Pointer(p) ((CInt64*)(p))
#define AsBitsPointer(p) ((BitsPointer)(p))

#define AsTaggedBoolean(p) ((AsWord(p) & ~(kTagBitsMask << kTagBitsShift)) | ((kTagBitsBoolean & kTagBitsMask)<<kTagBitsShift))
#define AsTaggedByte(p) ((AsWord(p) & ~(kTagBitsMask << kTagBitsShift)) | ((kTagBitsByte & kTagBitsMask)<<kTagBitsShift))
#define AsTaggedCharacter(p) ((AsWord(p) & ~(kTagBitsMask << kTagBitsShift)) | ((kTagBitsCharacter & kTagBitsMask)<<kTagBitsShift))
#define AsTaggedAddress(p) ((AsWord(p) & ~(kTagBitsMask << kTagBitsShift)) | ((kTagBitsAddress & kTagBitsMask)<<kTagBitsShift))
#define AsTaggedInteger(p) ((AsWord(p) & ~(kTagBitsMask << kTagBitsShift)) | ((kTagBitsInteger & kTagBitsMask)<<kTagBitsShift))
#define AsTaggedUInteger(p) ((AsWord(p) & ~(kTagBitsMask << kTagBitsShift)) | ((kTagBitsUInteger & kTagBitsMask)<<kTagBitsShift))
#define AsTaggedWord(p) ((AsWord(p) & ~(kTagBitsMask << kTagBitsShift)) | ((kTagBitsInteger & kTagBitsMask)<<kTagBitsShift))
#define AsTaggedFloat32(p) ((AsWord(p) & ~(kTagBitsMask << kTagBitsShift)) | ((kTagBitsFloat32 & kTagBitsMask)<<kTagBitsShift))
#define AsTaggedFloat64(p) ((AsWord(p) & ~(kTagBitsMask << kTagBitsShift)) | ((kTagBitsFloat64 & kTagBitsMask)<<kTagBitsShift))
#define AsTaggedBits(p) ((AsWord(p) & ~(kTagBitsMask << kTagBitsShift)) | ((kTagBitsBits & kTagBitsMask)<<kTagBitsShift))

#define AsUntaggedPointer(w) (AsPointer(AsWord(w) & ~(kTagBitsMask << kTagBitsShift)))
#define AsUntaggedWord(w) (AsWord(w) & ~(kTagBitsMask<<kTagBitsShift))
#define AsUntaggedAddress(w) (AsWord(w) & ~(kTagBitsMask<<kTagBitsShift))
#define AsUntaggedInteger(w) (AsInteger((w) & ~(kTagBitsMask<<kTagBitsShift)))
#define AsUntaggedUInteger(w) (AsUInteger((w) & ~(kTagBitsMask<<kTagBitsShift)))
#define AsUntaggedBoolean(w) (AsBoolean((w) & ~(kTagBitsMask<<kTagBitsShift)))
#define AsUntaggedFloat32(w) (AsFloat32(AsWord(w) & ~(kTagBitsMask<<kTagBitsShift)))
#define AsUntaggedFloat64(w) (AsFloat64(AsWord(w) & ~(kTagBitsMask<<kTagBitsShift)))
#define AsUntaggedBits(w) (AsBits(AsWord(w) & ~(kTagBitsMask<<kTagBitsShift)))
#define AsUntaggedAddress(w) (AsAddress(AsWord(w) & ~(kTagBitsMask<<kTagBitsShift)))
#define AsUntaggedByte(w) (AsByte((w) & ~(kTagBitsMask<<kTagBitsShift)))
#define AsUntaggedWordPointer(w) (AsWordPointer(AsWord(w) & ~(kTagBitsMask<<kTagBitsShift)))
#define AsUntaggedPointerPointer(w) (AsPointerPointer(AsWord(w) & ~(kTagBitsMask<<kTagBitsShift)))

Word wordAtAddress(Word address);
void setWordAtAddress(Word word,Word address);
char* charPointerToIndexAtAddress(SlotIndex index,Word pointer);
Word wordAtIndexAtAddress(SlotIndex index,Word pointer);
void setWordAtIndexAtAddress(Word word,SlotIndex index,Word address);
//
// GETTING VALUES AT ADDRESS
//
Word addressAtIndexAtAddress(SlotIndex index,Word address);
Word addressAtAddress(Word address);
long long integerAtIndexAtAddress(SlotIndex index,Word address);
long long integerAtAddress(Word address);
unsigned long long uintegerAtIndexAtAddress(SlotIndex index,Word address);
unsigned long long uintegerAtAddress(Word address);
_Bool booleanAtIndexAtAddress(SlotIndex index,Word address);
_Bool booleanAtAddress(Word address);
float float32AtIndexAtAddress(SlotIndex index,Word address);
float float32AtAddress(Word address);
unsigned char byteAtIndexAtAddress(SlotIndex index,Word address);
unsigned char byteAtAddress(Word address);
Word bitsAtIndexAtAddress(SlotIndex index,Word address);
Word bitsAtAddress(Word address);
//
// SETTING VALUES AT ADDRESS
//
void setAddressAtIndexAtAddress(Word inputAddress,SlotIndex index,Word address);
void setIntegerAtIndexAtAddress(long long integer,SlotIndex index,Word address);
void setAddressAtAddress(Word inputAddress,Word address);
void setIntegerAtAddress(long long integer,Word address);
void setUIntegerAtIndexAtAddress(unsigned long long integer,SlotIndex index,Word address);
void setUIntegerAtAddress(unsigned long long integer,Word address);
void setBooleanAtIndexAtAddress(_Bool boolean,SlotIndex index,Word address);
void setBooleanAtAddress(_Bool boolean,Word address);
void setFloat32AtIndexAtAddress(float aFloat,SlotIndex index,Word address);
void setFloat32AtAddress(float aFloat,Word address);
void setByteAtIndexAtAddress(unsigned char byte,SlotIndex index,Word address);
void setByteAtAddress(unsigned char,Word address);
void setBitsAtIndexAtAddress(Word bits,SlotIndex index,Word address);
void setBitsAtAddress(Word bits,Word address);

Word taggedWord(Word word);
Word taggedBoolean(_Bool word);
Word taggedInteger(CInt64 word);
Word taggedUInteger(CUInt64 word);
Word taggedByte(unsigned char byte);
Word taggedAddress(Word pointer);
Word taggedBits(Word bits);
Word taggedFloat32(float value);
_Bool untaggedBoolean(_Bool word);
CInt64 untaggedInteger(CInt64 word);
CUInt64 untaggedUInteger(CUInt64 word);
CUInt64 untaggedBits(CUInt64 word);
unsigned char untaggedByte(unsigned char byte);
float untaggedFloat32(float value);
Word untaggedAddress(Word value);
Word untaggedWord(Word word);
Word untaggedWordAtAddress(Word address);
Word bitWordAtIndexAtAddress(SlotIndex index,Word pointer);
void setBitWordAtIndexAtAddress(Word word,SlotIndex index,Word pointer);

#endif /* RawMemory_h */
