#ifndef CORE_H
#define CORE_H

#include "common.h"

//! @brief Computes hash of 'len' bytes of 'data'
hash_t compute_hash(char *data, size_t len);

//! @brief Cures given ProgFile, changing some bytes.
StatusCode cure( ProgFile *prog_file_ptr );

#endif /* CORE_H */
