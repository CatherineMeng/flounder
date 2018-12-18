#include "adj_ops.h"

static int const fevi[3][2] = {{0,1},{1,2},{2,0}};

struct rgraph compute_fes(struct rgraph fvs, struct graph ves)
{
  struct adj ve[2];
  ve[0] = adj_new(ves.max_deg);
  ve[1] = adj_new(ves.max_deg);
  struct rgraph fes = rgraph_new(fvs.nverts, 3);
  for (int i = 0; i < fvs.nverts; ++i) { // loop over faces
    int fv[3];
    rgraph_get(fvs, i, fv);              // get vertices adj to face
    int fe[3];
    for (int j = 0; j < 3; ++j) {        // loop over vertices
      int ev[2];
      for (int k = 0; k < 2; ++k)
        ev[k] = fv[fevi[j][k]];          // store the edge vertices in a specific order
      for (int k = 0; k < 2; ++k)
        graph_get(ves, ev[k], &ve[k]);   // get edges adj to each vertex
      adj_intersect(&ve[0], ve[1]);      // intersect the two sets of edges
      fe[j] = ve[0].e[0];                // store the intersection
    }
    rgraph_set(fes, i, fe);
  }
  adj_free(ve[0]);
  adj_free(ve[1]);
  return fes;
}
