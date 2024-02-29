#ifndef COMMON_H
#define COMMON_H

#include <stdio.h>
#include <assert.h>


#define ASSERT_UNREACHEABLE() assert(0 && "Unreacheable")


typedef long long hash_t;
typedef unsigned char byte;


enum StatusCode
{
    STATUS_OK,
    STATUS_ERR_CANT_GET_FILE_SIZE,
    STATUS_ERR_CANT_OPEN_FILE,
    STATUS_ERR_CANT_CREATE_FILE,
    STATUS_ERR_CANT_READ_PROG_FILE,
    STATUS_ERR_DURING_WRITING_INTO_FILE,
    STATUS_ERR_NO_INP_FILE_SPECIFIED,
};

enum Result
{
    RES_DEFAULT,
    RES_PROG_CURED,
    RES_GIVEN_PROG_ALREADY_CURED,
    RES_GIVEN_PROG_IS_WRONG,
};

struct ProgFile
{
    char * data;
    size_t data_size;
};

struct ByteToCure
{
    size_t byte_offset; //< Index in the array of file's data.
    byte byte_cured;    //< Value of the byte in the cured program.
};



const hash_t HASH_UNCURED_REF       = 0;
const hash_t HASH_CURED_REF         = 0;
const ByteToCure BYTES_TO_CURE[]    =
{

};
const size_t NUM_OF_BYTES_TO_CURE = sizeof( BYTES_TO_CURE ) / sizeof( BYTES_TO_CURE[0] );



void ProgFile_dtor( ProgFile *ptr );

#endif /* COMMON_H */
