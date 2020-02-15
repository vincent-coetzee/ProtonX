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
    
typedef struct _Float64
    {
    Word header;
    double float64;
    }
    PrivateFloat64;

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
#define kInstanceFlag               ((Word)1)
#define kInstanceFlagMask           (((Word)1) << ((Word)63))
#define kInstanceFlagShift          ((Word)63)
//
// TAG FLAGS FOR THE HEADER WORD
//

#define kTagBitsInteger           ((Word)0)
#define kTagBitsUInteger          ((Word)1)
#define kTagBitsFloat32           ((Word)2)
#define kTagBitsBoolean           ((Word)3)
#define kTagBitsByte              ((Word)4)
#define kTagBitsAddress           ((Word)5)
#define kTagBitsBits              ((Word)6)
#define kTagBitsPersistent        ((Word)7)

#define kTagBitsMask               ((Word)7)
#define kTagBitsShift              ((Word)60)
//
// SIZE MASKS AND SHIFTS FOR HEADER WORD
//
#define kSlotCountMask              ((Word)4294967295)
#define kSlotCountShift             ((Word)8)
//
// HEADER FLAGS FOR TYPES
//
#define kTypeMethodInstance = ((Word)1)
#define kTypeString = ((Word)2)
#define kTypeDictionary = ((Word)3)
#define kTypeSet = ((Word)4)
#define kTypeBitSet = ((Word)5)
#define kTypeArray = ((Word)6)
#define kTypeList = ((Word)7)
#define kTypeAlias = ((Word)8)
#define kTypeEnumeration = ((Word)9)
#define kTypeType = ((Word)10)
#define kTypeUser = ((Word)11)
#define kTypeWordBuffer = ((Word)12)
#define kTypeSlot = ((Word)14)
#define kTypeVirtualSlot = ((Word)15)
#define kTypeSystemSlot = ((Word)16)
#define kTypeCodeBlock = ((Word)17)
#define kTypeClosure = ((Word)18)
#define kTypeInstance = ((Word)19)
#define kTypeMetaType = ((Word)20)
#define kTypeSigned = ((Word)21)
#define kTypeUnsigned = ((Word)22)
#define kTypeBoolean = ((Word)23)
#define kTypeCharacter = ((Word)24)
#define kTypeByte = ((Word)25)
#define kTypeCollection = ((Word)26)
#define kTypeObject = ((Word)27)
#define kTypeContract = ((Word)28)
#define kTypeMethod = ((Word)29)
#define kTypeFloat32 = ((Word)30)
#define kTypeFloat64 = ((Word)31)
#define kTypeStringDictionary = ((Word)32)
#define kTypeTypeType = ((Word)33)
#define kTypeStringType = ((Word)34)

#define kTypeMask                     ((Word)255)
#define kTypeShift                    ((Word)0)

#define kHighHalfWordShift            ((Word)32)
#define kHalfWordMask                 ((Word)4294967295)

#define kHeaderMarkerMask             ((Word)1)
#define kHeaderMarkerShift            ((Word)59)
#define kHeaderMarkerMaskShifted      (((Word)1) << ((Word)59))

//
// WORD MACROS
//
#define WordFromHighLow(h,l) (((AsWord(h) & kHalfWordMask) << kHighHalfWordShift) | (AsWord(l) & kHalfWordMask))
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

//Word wordAtPointer(void* pointer);
//void* pointerAtPointer(void* pointer);
//Word untaggedWordAtPointer(void* pointer);
//void setWordAtPointer(Word word,void* pointer);
//void setAddressAtPointer(Word word,void* pointer);
//void setWordAtIndexAtPointer(Word word,SlotIndex index,void* pointer);
//Word wordAtIndexAtPointer(SlotIndex index,void* pointer);
//void setTaggedWordAtIndexAtPointer(Word word,SlotIndex index,void* pointer);
//void setInt64AtIndexAtPointer(CInt64 value,SlotIndex index,void* pointer);
//Word pointerAsWord(void* pointer);
//Word pointerAsAddress(void* pointer);
//void* wordAsPointer(Word word);
Word wordAtAddress(Word address);
void setWordAtAddress(Word word,Word address);
//void setPointerAtIndexAtPointer(void* pointer,SlotIndex index,void* targetPointer);
//void setObjectPointerAtIndexAtPointer(void* pointer,SlotIndex index,void* targetPointer);
//void tagAndSetPointerAtIndexAtPointer(void* pointer,SlotIndex index,void* targetPointer);
//void tagAndSetAddressAtIndexAtPointer(Word address,SlotIndex index,void* targetPointer);
//void* pointerAtIndexAtPointer(SlotIndex index,void* pointer);
char* charPointerToIndexAtAddress(SlotIndex index,Word pointer);
//void* pointerToIndexAtPointer(SlotIndex index,void* pointer);
Word wordAtIndexAtAddress(SlotIndex index,Word pointer);
//void* untaggedPointerAtAddress(Word address);
//Word untaggedPointerAsAddress(void* pointer);
void setWordAtIndexAtAddress(Word word,SlotIndex index,Word address);
//void setAddressAtIndexAtPointer(Word word,SlotIndex index,void* pointer);
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
//Word taggedObjectAddress(Word pointer);
Word taggedFloat32(float value);
//PrivateFloat64 taggedFloat64(Word header,double value);
_Bool untaggedBoolean(_Bool word);
CInt64 untaggedInteger(CInt64 word);
CUInt64 untaggedUInteger(CUInt64 word);
CUInt64 untaggedBits(CUInt64 word);
unsigned char untaggedByte(unsigned char byte);
//void* untaggedObject(void* pointer);
float untaggedFloat32(float value);
//double untaggedFloat64(PrivateFloat64 words);
Word untaggedAddress(Word value);
//Word untaggedWordAtIndexAtPointer(SlotIndex index,void* pointer);
//Word untaggedBitsAtIndexAtPointer(SlotIndex index,void* pointer);
//void setTaggedBitsAtIndexAtPointer(Word bits,SlotIndex index,void* pointer);
//Word untaggedAddressAtIndexAtPointer(SlotIndex index,void* pointer);
//void* untaggedPointerAtIndexAtPointer(SlotIndex index,void* pointer);
//void* untaggedPointerToIndexAtPointer(SlotIndex index,void* pointer);
Word untaggedWord(Word word);
//void* untaggedPointer(void* pointer);
//void* untaggedWordAsPointer(Word word);
//void* untaggedAddressAsPointer(Word address);
Word untaggedWordAtAddress(Word address);
//CInt64 untaggedIntegerAtIndexAtPointer(SlotIndex index,void* pointer);
//void setTaggedIntegerAtIndexAtPointer(CInt64 word,SlotIndex index,void* pointer);
//void setTaggedUIntegerAtIndexAtPointer(CUInt64 word,SlotIndex index,void* pointer);
//void setTaggedByteAtIndexAtPointer(Byte word,SlotIndex index,void* pointer);
//void setTaggedBooleanAtIndexAtPointer(_Bool word,SlotIndex index,void* pointer);
//void setTaggedFloat32AtIndexAtPointer(float word,SlotIndex index,void* pointer);
//void setTaggedFloat64AtIndexAtPointer(double word,SlotIndex index,void* pointer);
//void setTaggedObjectAddressAtIndexAtPointer(Word address,SlotIndex index,void* pointer);
//void setTaggedObjectPointerAtIndexAtPointer(void* address,SlotIndex index,void* pointer);
//CUInt64 untaggedUIntegerAtIndexAtPointer(SlotIndex index,void* pointer);
//float untaggedFloat32AtIndexAtPointer(SlotIndex index,void* pointer);
//double untaggedFloat64AtIndexAtPointer(SlotIndex index,void* pointer);
//_Bool untaggedBooleanAtIndexAtPointer(SlotIndex index,void* pointer);
//Byte untaggedByteAtIndexAtPointer(SlotIndex index,void* pointer);
//Word untaggedAddressAtIndexAtPointer(SlotIndex index,void* pointer);
Word bitWordAtIndexAtAddress(SlotIndex index,Word pointer);
void setBitWordAtIndexAtAddress(Word word,SlotIndex index,Word pointer);
//Word addressOfIndexAtPointer(SlotIndex index,void* pointer);

//
// TAGGING
//
//Word pointerAsTaggedObjectAddress(void* pointer);

#endif /* RawMemory_h */
