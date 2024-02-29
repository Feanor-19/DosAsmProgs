#ifndef INOUT_H
#define INOUT_H

#include "common.h"


const size_t MAX_FILE_NAME_LEN = 128;


//! @brief Attempts to read file with name 'file_name' into given ProgFile.
StatusCode read_prog_file( ProgFile *prog_file_ptr, const char *file_name );

//! @brief Writes given prog_file into CURED_*file_name*
StatusCode write_prog_file( ProgFile *prog_file_ptr, const char *file_name );

void tell_result( Result res );

void print_err_msg( StatusCode err );

#endif /* INOUT_H */
