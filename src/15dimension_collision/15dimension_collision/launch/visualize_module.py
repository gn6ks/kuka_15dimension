import os
from ament_index_python.packages import get_package_share_directory
from launch import LaunchDescription
from launch_ros.actions import Node

def generate_launch_description():

    pkg = get_package_share_directory('15dimension_collision')
    urdf_file = os.path.join(pkg, 'urdf', 'kuka_kr15.urdf')

    with open(urdf_file, 'r') as f:
        robot_description = f.read()

    return LaunchDescription([

        # Publica las transformaciones TF a partir del URDF
        Node(
            package='robot_state_publisher',
            executable='robot_state_publisher',
            parameters=[{'robot_description': robot_description}]
        ),

        # Sliders manuales para mover cada articulación
        Node(
            package='joint_state_publisher_gui',
            executable='joint_state_publisher_gui',
        ),

        # Visualizador 3D
        Node(
            package='rviz2',
            executable='rviz2',
        ),

    ])