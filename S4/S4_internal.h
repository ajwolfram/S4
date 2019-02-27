/* Copyright (C) 2009-2011, Stanford University
 * This file is part of S4
 * Written by Victor Liu (vkl@stanford.edu)
 *
 * S4 is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * S4 is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#ifndef _S4_H_
#define _S4_H_

#include <stdio.h>

// Note: the interface described in this file must be kept C-compatible.

#ifdef __cplusplus
#include <complex>
extern "C" {
#endif
//#include "pattern/pattern.h"
struct Patterning;
#ifdef __cplusplus
}
#endif


#ifdef ENABLE_S4_TRACE
# ifdef __cplusplus
#  include <cstdio>
# else
#  include <stdio.h>
# endif
# define S4_TRACE(...) fprintf(stderr, __VA_ARGS__)
# define S4_CHECK if(1)
#else
# define S4_TRACE(...)
# define S4_CHECK if(0)
#endif




#define S4_VERB(verb,...) \
	do{ \
		if(S->options.verbosity >= verb){ \
			fprintf(stdout, "[%d] ", verb); \
			fprintf(stdout, __VA_ARGS__); \
		} \
	}while(0)

#ifdef __cplusplus
# include <cstdlib>
#else
# include <stdlib.h>
#endif

typedef struct{
	char *name;    // name of material
	int type; // 0 = scalar epsilon, 1 = tensor
	union{
		double s[2]; // real and imaginary parts of epsilon
		double abcde[10];
		// [ a b 0 ]
		// [ c d 0 ]
		// [ 0 0 e ]
	} eps;
} S4_Material;

/*
#define S4_TENSOR_REAL   0x0001
#define S4_TENSOR_POSDEF 0x0002
#define S4_TENSOR_SCALAR 0x0010
#define S4_TENSOR_DIAG   0x0020
#define S4_TENSOR_HERM   0x0040
#define S4_TENSOR_SYMM   0x0080
#define S4_TENSOR_ZORTH  0x0100

struct S4_Material{
	S4_real eps[18];
	unsigned int flags;
	std::string name;
	S4_Material(){
		eps[ 0] = 1; eps[ 1] = 0; eps[ 2] = 0; eps[ 3] = 0; eps[ 4] = 0; eps[ 5] = 0;
		eps[ 6] = 0; eps[ 7] = 0; eps[ 8] = 1; eps[ 9] = 0; eps[10] = 0; eps[11] = 0;
		eps[12] = 0; eps[13] = 0; eps[14] = 0; eps[15] = 0; eps[16] = 1; eps[17] = 0;
		flags = (S4_TENSOR_REAL | S4_TENSOR_POSDEF | S4_TENSOR_SCALAR | S4_TENSOR_DIAG | S4_TENSOR_HERM | S4_TENSOR_SYMM | S4_TENSOR_ZORTH);
	}
};
*/

struct LayerModes;
typedef struct{
	char *name;       // name of layer
	double thickness; // thickness of layer
	S4_MaterialID material;   // name of background material
	//Pattern pattern;  // See pattern.h
	struct Patterning *pat;
	S4_LayerID copy;       // See below.
	struct LayerModes *modes;
} S4_Layer;
// If a layer is a copy, then `copy' is the name of the layer that should
// be copied, and `material' and `pattern' are inherited, and so they can
// be arbitrary. For non-copy layers, copy should be NULL.

struct FieldCache;

typedef struct Excitation_Planewave_{
	double hx[2],hy[2]; // re,im components of H_x,H_y field
	size_t order;
	int backwards;
} Excitation_Planewave;

typedef struct Excitation_Dipole_{
	double pos[2];
	double moment[6]; // dipole moment (jxr, jxi, jyr, jyi, jzr, jzi)
	// The source is at the layer interface after the layer specified by ex_layer.
} Excitation_Dipole;

typedef struct Excitation_Exterior_{
	size_t n;
	int *Gindex1; /* 1-based G index, negative means backwards (length n) */
	double *coeff; /* complex coefficients of each G index (length 2n) */
} Excitation_Exterior;

typedef struct Excitation_{
	union{
		Excitation_Planewave planewave; // type 0
		Excitation_Dipole dipole; // type 1
		Excitation_Exterior exterior; // type 2
	} sub;
	int type;
	S4_Layer *layer; // name of layer after which excitation is applied
} Excitation;

struct Solution_;
struct S4_Simulation_{
	double Lr[4]; // real space lattice:
	              //  {Lr[0],Lr[1]} is the first basis vector's x and y coords.
	              //  {Lr[2],Lr[3]} is the second basis vector's x and y coords.
	double Lk[4]; // reciprocal lattice:
	              //  2pi*{Lk[0],Lk[1]} is the first basis vector's x and y coords.
	              //  2pi*{Lk[2],Lk[3]} is the second basis vector's x and y coords.
	              // Computed by taking the inverse of Lr as a 2x2 column-major matrix.
	int n_G;            // Number of G-vectors (Fourier planewave orders).
	int *G; // length 2*n_G; uv coordinates of Lk
	int G_max;
	double *kx, *ky; // each length n_G
	int n_materials, n_materials_alloc;
	S4_Material *material; // array of materials
	int n_layers, n_layers_alloc;
	S4_Layer *layer;       // array of layers

	// Excitation
	double omega[2]; // real and imaginary parts of omega
	double k[2]; // xy components of k vector, as fraction of k0 = omega
	Excitation exc;

	struct Solution_ *solution; // The solution object is not allocated until needed.
	S4_Options options;

	struct FieldCache *field_cache; // Internal cache of vector field FT when using polarization bases
	
	S4_message_handler msg;
	void *msgdata;
};

#ifdef __cplusplus
extern "C" {
#endif



//// Layer methods
void Layer_Destroy(S4_Layer *L);

//// Material methods
void Material_Destroy(S4_Material *M);

//// Simulation methods

void Simulation_DestroySolution(S4_Simulation *S);
void Simulation_DestroyLayerSolutions(S4_Simulation *S);
void Simulation_DestroyLayerModes(S4_Layer *layer);
void S4_Simulation_DestroyLayerModes(S4_Simulation *S, S4_LayerID id);

// Destroys the solution belonging to a given simulation and sets
// S->solution to NULL.

///////////////// Simulation parameter specifications /////////////////
// These will invalidate any existing partially computed solutions.

// Assumes that S->Lr is filled in, and computes Lk.
// For 1D lattices, S->Lr[2] = S->Lr[3] = 0, and the corresponding
// Lk[2] and Lk[3] are set to 0.
// Returns:
//  -1 if S is NULL
//   0 on success
//   1 if basis vectors are degenerate (rank Lr < 2)
//   2 if basis vectors are zero (Lr == 0)
int Simulation_MakeReciprocalLattice(S4_Simulation *S);

int Simulation_SetNumG(S4_Simulation *S, int n);
int Simulation_GetNumG(const S4_Simulation *S, int **G);
double Simulation_GetUnitCellSize(const S4_Simulation *S);

// Returns NULL if the layer name could not be found, or on error.
// If index is non-NULL, the offset of the layer in the list is returned.
S4_Layer* Simulation_GetLayerByName(const S4_Simulation *S, const char *name, int *index);

// Returns NULL if the material name could not be found, or on error.
// If index is non-NULL, the offset of the material in the list is returned.
S4_Material* Simulation_GetMaterialByName(const S4_Simulation *S, const char *name, int *index);
S4_Material* Simulation_GetMaterialByIndex(const S4_Simulation *S, int i);

// Returns 14 if no layers present
// exg is length 2*n, pairs of G index (1-based index, negative for backwards modes), and 0,1 polarization (E field x,y)
// ex is length 2*n, pairs of re,im complex coefficients
int Simulation_MakeExcitationExterior(S4_Simulation *S, int n, const int *exg, const double *ex);
int Simulation_MakeExcitationPlanewave(S4_Simulation *S, const double angle[2], const double pol_s[2], const double pol_p[2], size_t order);
int Simulation_MakeExcitationDipole(S4_Simulation *S, const double k[2], const char *layer, const double pos[2], const double moment[6]);


// Internal functions
#ifdef __cplusplus
// Field cache manipulation
void Simulation_InvalidateFieldCache(S4_Simulation *S);
std::complex<double>* Simulation_GetCachedField(const S4_Simulation *S, const S4_Layer *layer);
//S4_complex* Simulation_GetCachedField(const S4_Simulation *S, const S4_Layer *layer);
//void Simulation_AddFieldToCache(S4_Simulation *S, const S4_Layer *layer, size_t n, const S4_complex *P, size_t Plen);
//void Simulation_AddFieldToCache(S4_Simulation *S, const S4_Layer *layer, size_t n, const std::complex<double> *P, size_t Plen);
void Simulation_AddFieldToCache(S4_Simulation *S, const S4_Layer *layer, size_t n, const S4_complex *P, size_t Plen, const S4_complex *W, size_t Wlen);
#endif

//////////////////////// Simulation solutions ////////////////////////
// These functions try to compute the minimum amount necessary to
// obtain the desired result. All partial solutions are stored so
// that later requerying of the same results returns the stored
// result.

// Solution error codes:
// -n - n-th argument is invalid
// 0  - successful
// 1  - allocation error
// 9  - lattice n_G not set
// 10 - copy referenced an unknown layer name
// 11 - a copy of a copy was made
// 12 - duplicate layer name found
// 13 - excitation layer name not found
// 14 - no layers
// 15 - material not found


// Sets up S->solution; if one already exists, destroys it and allocates a new one
// Possibly reduces S->n_G
// Returns a solution error code
int Simulation_InitSolution(S4_Simulation *S);

// Returns a solution error code
int Simulation_SolveLayer(S4_Simulation *S, S4_Layer *layer);

// Returns a solution error code
// E field is stored as {Exr,Eyr,Ezr,Exi,Eyi,Ezi}
int Simulation_GetField(S4_Simulation *S, const double r[3], double fE[6], double fH[6]);
int Simulation_GetFieldPlane(S4_Simulation *S, int nxy[2], double z, double *E, double *H);

// Returns a solution error code
int Simulation_GetEpsilon(S4_Simulation *S, const double r[3], double eps[2]); // eps is {real,imag}

// Returns a solution error code
// Determinant is (rmant[0]+i*rmant[1])*base^expo
int Simulation_GetSMatrixDeterminant(S4_Simulation *S, double rmant[2], double *base, int *expo);


#ifdef __cplusplus
}
#endif

#endif // _S4_H_
