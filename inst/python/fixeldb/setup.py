import setuptools

with open("README.md", "r") as fh:
    long_description = fh.read()
#with open("requirements.txt", "r") as fh:
#    requirements = fh.read().splitlines()

setuptools.setup(
    name="FixelArray",
    version="0.0.1",
    author="Tinashe M. Tapera, Matt Cieslak",
    author_email="tinashemtapera@gmail.com",
    description="Convert mrtrix fixel output to H5 for mass univariate analysis",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/PennBBL/FixelDB",
    packages=setuptools.find_packages(),
    install_requires=[
        "nibabel",
        "pandas",
        "tqdm",
        "h5py"
    ],
    classifiers=[
        "Programming Language :: Python :: 3.6",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    entry_points={
        'console_scripts': [
            'fixel-backend-create=fixels:main',
        ],
    }
)
