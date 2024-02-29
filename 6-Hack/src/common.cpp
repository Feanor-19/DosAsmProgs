#include "common.h"

void ProgFile_dtor( ProgFile *ptr )
{
    free(ptr->data);

    ptr->data = NULL;
    ptr->data_size = 0;
}
