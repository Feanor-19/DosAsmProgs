#include <stdio.h>

#include "inout.h"
#include "core.h"

#define PRINT_ERROR_MSG_AND_RET_IF(cond, err) \
    do {if ( (cond) ) { print_err_msg(err); getchar(); return err; } } while(0)

//! ATTENTION
//! In order to change the program to cure, see common.h
//! and change HASH_UNCURED_REF, HASH_CURED_REF, BYTES_TO_CURE

int main( int argc, const char *argv[] )
{
    PRINT_ERROR_MSG_AND_RET_IF( argc < 2, STATUS_ERR_NO_INP_FILE_SPECIFIED );
    const char *file_name = argv[1];

    StatusCode st_code = STATUS_OK;
    ProgFile prog_file = {};

    st_code = read_prog_file( &prog_file, file_name );
    PRINT_ERROR_MSG_AND_RET_IF( st_code != STATUS_OK, st_code );

    hash_t hash_uncured = compute_hash( prog_file.data, prog_file.data_size );

    Result res = RES_DEFAULT;
    if ( hash_uncured != HASH_UNCURED_REF )
    {
        if ( hash_uncured != HASH_CURED_REF )
            res = RES_GIVEN_PROG_IS_WRONG;
        else
            res = RES_GIVEN_PROG_ALREADY_CURED;
    }

    if (res == RES_DEFAULT)
    {
        st_code = cure( &prog_file );
        res = RES_PROG_CURED;
    }

    tell_result( res );

    if ( res == RES_PROG_CURED )
    {
        write_prog_file( &prog_file, file_name );
    }

    ProgFile_dtor( &prog_file );

    return STATUS_OK;
}
