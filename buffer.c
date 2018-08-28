#include "buffer.h"

void buffer_init(buffer *s,io_op* op,int fd,char *buf,unsigned int len)
{
  s->x = buf;
  s->fd = fd;
  s->op = op;
  s->p = 0;
  s->n = len;
}

int readop(int fd, char *buf, unsigned int count) {
  return (int)read(fd, (void *)buf, (size_t)count);
}

int writeop(int fd, char *buf, unsigned int count) {
  return (int)write(fd, (const void*)buf, (size_t)count);
}
