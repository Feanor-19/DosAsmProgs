#include "inout.h"

#include <sys/stat.h>
#include <sys/types.h>

//! @brief Writes file's size into size_ptr. If error occurs,
// corresponding status code is returned.
inline StatusCode get_file_size(const char *file_name, size_t *size_ptr)
{
    assert(file_name);

    struct stat st_buf = {};
    if ( stat(file_name, &st_buf) == -1)
        return STATUS_ERR_CANT_GET_FILE_SIZE;

    *size_ptr = (size_t) st_buf.st_size;
    return STATUS_OK;
}

StatusCode read_prog_file( ProgFile *prog_file_ptr, const char *file_name )
{
    assert(file_name);
    assert(prog_file_ptr);
    StatusCode code = STATUS_OK;

    size_t file_size = 0;
    if ( (code = get_file_size( file_name, &file_size ) ) != STATUS_OK )
    {
        return code;
    }

    FILE *file_ptr = fopen( file_name, "rb" );
    if ( file_ptr == NULL )
    {
        return STATUS_ERR_CANT_OPEN_FILE;
    }

    char *data = (char *) calloc( file_size, sizeof(char) );

    size_t data_size = fread( data, sizeof(char), file_size, file_ptr );
    if ( ferror(file_ptr) != 0 )
    {
        free( data );
        return STATUS_ERR_CANT_OPEN_FILE;
    }

    fclose(file_ptr);

    prog_file_ptr->data = data;
    prog_file_ptr->data_size = data_size;

    return STATUS_OK;
}

StatusCode write_prog_file( ProgFile *prog_file_ptr, const char *file_name )
{
    assert(prog_file_ptr);
    assert(file_name);

    FILE *file_ptr = fopen( file_name, "wb" );
    if ( file_ptr == NULL )
        return STATUS_ERR_CANT_CREATE_FILE;

    size_t written = fwrite( prog_file_ptr->data, sizeof(char), prog_file_ptr->data_size, file_ptr );
    if (written != prog_file_ptr->data_size)
        return STATUS_ERR_DURING_WRITING_INTO_FILE;

    return STATUS_OK;
}

void tell_result( Result res )
{
    switch (res)
    {
    case RES_GIVEN_PROG_ALREADY_CURED:
        fprintf(stdout, "The given program is already cured!\n");
        break;
    case RES_GIVEN_PROG_IS_WRONG:
        fprintf(stdout, "It seems like the given program is not the one, "
                "which is supposed to be cured by this very pill. Consult "
                "your doctor, please!\n");
        break;
    case RES_PROG_CURED:
        fprintf(stdout, "Congratulations! The program is successfully cured!\n" );
        break;
    case RES_DEFAULT:
    default:
        ASSERT_UNREACHEABLE();
        break;
    }
}

void print_err_msg( StatusCode err )
{
    switch (err)
    {
    case STATUS_OK:
        fprintf(stderr, "STATUS: OK. No error.");
        break;
    case STATUS_ERR_CANT_GET_FILE_SIZE:
        fprintf(stderr, "ERROR: CANT_GET_FILE_SIZE.");
        break;
    case STATUS_ERR_CANT_OPEN_FILE:
        fprintf(stderr, "ERROR: CANT_OPEN_FILE.");
        break;
    case STATUS_ERR_CANT_CREATE_FILE:
        fprintf(stderr, "ERROR: CANT_CREATE_FILE.");
        break;
    case STATUS_ERR_CANT_READ_PROG_FILE:
        fprintf(stderr, "ERROR: CANT_READ_PROG_FILE.");
        break;
    case STATUS_ERR_DURING_WRITING_INTO_FILE:
        fprintf(stderr, "ERROR: ERR_DURING_WRITING_INTO_FILE.");
        break;
    case STATUS_ERR_NO_INP_FILE_SPECIFIED:
        fprintf(stderr, "ERROR: NO_INP_FILE_SPECIFIED.");
        break;
    default:
        ASSERT_UNREACHEABLE();
        break;
    }
}
