#ifndef GRAPH_H
#define GRAPH_H

#include "adj.cuh"
#include "ints.cuh"
#include <assert.h>

struct graph_spec {
  int nverts;
  struct ints deg;
};

struct graph {
  int nverts;
  int max_deg;
  struct ints off;
  struct ints adj;
};

struct graph_spec graph_spec_new(int nverts);
struct graph graph_new(struct graph_spec s);
void graph_free(struct graph g);

int graph_nedges(struct graph const g);

static __device__ inline int graph_deg(struct graph g, int i)
{
  return g.off.i[i + 1] - g.off.i[i];
}

static __device__ inline void graph_get(struct graph g, int i, struct adj* a)
{
  int* p = g.adj.i + g.off.i[i];
  int* e = g.adj.i + g.off.i[i + 1];
  a->n = e - p;
  int* q = a->e;
  while (p < e)
    *q++ = *p++;
}

static __device__ inline void graph_set(struct graph g, int i, struct adj a)
{
  int* p = g.adj.i + g.off.i[i];
  int* e = g.adj.i + g.off.i[i + 1];
  int* q = a.e;
  while (p < e)
    *p++ = *q++;
}

static __device__ inline struct adj adj_new_graph(struct graph g)
{
  return adj_new(g.max_deg);
}

#endif
