"""
    A simple program taking two inputs: the first is the main nifti file. The second is a nifti file with the desired header. This takes the data from nifti 1 and gives it the header of nifti 2. Re-writes nifti 1.

Usage:
    python transerNiftiHeader.py [data.nii] [header.nii]

"""
import nibabel as nib
import sys

# Input arguments
data_nii_path = sys.argv[1]
header_nii_path = sys.argv[2]

# Read nifti 1 
data_nii = nib.load(data_nii_path)
vol = data_nii.get_data()

# Read nifti 2 
header_nii = nib.load(header_nii_path)
affine = header_nii.affine
header = header_nii.header

# Convert nifti 1 to the dtype of nifti 2
vol = vol.astype(header_nii.get_data().dtype)

# Write over nifti 1
nii_out = nib.Nifti1Image(vol, affine, header=header)
nib.save(nii_out, data_nii_path)
