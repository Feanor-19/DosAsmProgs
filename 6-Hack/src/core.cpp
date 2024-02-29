#include "core.h"

hash_t compute_hash(char *_data, size_t len)
{
    const size_t m = 0x5bd1e995;
    const size_t seed = 0;
    const int r = 24;

    size_t hash = seed ^ len;

    const unsigned char *data = (const unsigned char *) _data;
    size_t k = 0;

    while (len >= 4)
    {
        k  = data[0];
        k |= data[1] << 8;
        k |= data[2] << 16;
        k |= data[3] << 24;

        k *= m;
        k ^= k >> r;
        k *= m;

        hash *= m;
        hash ^= k;

        data += 4;
        len -= 4;
    }

    switch (len)
    {
        case 3:
        hash ^= data[2] << 16;
        // fall through
        case 2:
        hash ^= data[1] << 8;
        // fall through
        case 1:
        hash ^= data[0];
        hash *= m;
        // fall through
        default:
        break;
    };

    hash ^= hash >> 13;
    hash *= m;
    hash ^= hash >> 15;

    return hash;
}

StatusCode cure( ProgFile *prog_file_ptr )
{
    assert(prog_file_ptr);
    assert(prog_file_ptr->data);

    for (size_t ind = 0; ind < NUM_OF_BYTES_TO_CURE; ind++)
    {
        ByteToCure curr = BYTES_TO_CURE[ind];
        prog_file_ptr->data[ curr.byte_offset ] = curr.byte_cured;
    }

    return STATUS_OK;
}
