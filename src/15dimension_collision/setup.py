from setuptools import find_packages, setup
import os
from glob import glob

package_name = '15dimension_collision'

setup(
    name=package_name,
    version='0.0.0',
    packages=find_packages(exclude=['test']),
    data_files=[
        ('share/ament_index/resource_index/packages',
            ['resource/' + package_name]),
        ('share/' + package_name, ['package.xml']),
        (os.path.join('share', package_name, 'urdf'),   glob('urdf/*')),
        (os.path.join('share', package_name, 'meshes'), glob('meshes/*')),
        (os.path.join('share', package_name, 'launch'), glob('launch/*.py')),
        (os.path.join('share', package_name, 'config'), glob('config/*.rviz')),
    ],
    install_requires=['setuptools'],
    zip_safe=True,
    maintainer='gn6ks',
    maintainer_email='pguifon@idf.upv.es',
    description='KR10 KUKA 2-Robot Simulation Space in 15 Dimensions with collision detection algorithms',
    license='MIT',
    extras_require={
        'test': ['pytest'],
    },
    entry_points={
        'console_scripts': [
            # AÑADIR CUANDO TENGAS LOS NODOS:
        ],
    },
)