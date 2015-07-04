#include "ints.cuh"
#include "mycuda.cuh"
#include <assert.h>
#include <limits.h>
#include <thrust/reduce.h>
#include <thrust/device_ptr.h>

struct ints ints_new(int n)
{
  struct ints is;
  is.n = n;
  cudaMalloc(&is.i, sizeof(int) * n);
  return is;
}

void ints_free(struct ints is)
{
  cudaFree(is.i);
}

struct ints ints_exscan(struct ints is)
{
  struct ints o = ints_new(is.n + 1);
  thrust::device_ptr<int> inp(is.i);
  thrust::device_ptr<int> outp(o.i);
  thrust::exclusive_scan(inp, inp + is.n, outp);
  /* fixup the last element quirk */
  int sum = thrust::reduce(inp, inp + is.n);
  cudaMemcpy(o.i + is.n, &sum, sizeof(int), cudaMemcpyHostToDevice);
  return o;
}

int ints_max(struct ints is)
{
  thrust::device_ptr<int> p(is.i);
  return thrust::reduce(p, p + is.n, INT_MIN, thrust::maximum<int>());
}

void ints_zero(struct ints is)
{
  cudaMemset(is.i, 0, sizeof(int) * is.n);
}

void ints_copy(struct ints into, struct ints from)
{
  assert(into.n >= from.n);
  cudaMemcpy(into.i, from.i, sizeof(int) * from.n, cudaMemcpyDeviceToDevice);
}

void ints_from_host(struct ints is, int const host_dat[])
{
  cudaMemcpy(is.i, host_dat, sizeof(int) * is.n, cudaMemcpyHostToDevice);
}
