from setuptools import setup, find_packages

setup(
    name='zippy',
    version='2.3.6-rc0',
    long_description=__doc__,
    packages=find_packages(),
    package_data={'zippy': ['templates/*', 'static/*', 'zippy.json']},
    include_package_data=True,
    install_requires=[
        'Flask>=0.10.1',
        'Werkzeug>=0.11.4',
        'bcrypt>=2.0.0',
        'primer3-py>=0.5.0',
        'pysam>=0.9.0',
        'reportlab>=3.3.0'],
    setup_requires=['Cython']
)
