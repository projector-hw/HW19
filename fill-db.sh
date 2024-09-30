#!/bin/bash

while true; do
    # Execute the sensors command and store the output in a variable
    sensor_output=$(sensors)

    # Extract the processor temperature (Package id 0)
    processor_temp=$(echo "$sensor_output" | awk '/Package id 0:/ {print $4}' | tr -d '+°C')

    # Extract core temperatures
    core0_temp=$(echo "$sensor_output" | awk '/Core 0:/ {print $3}' | tr -d '+°C')
    core1_temp=$(echo "$sensor_output" | awk '/Core 1:/ {print $3}' | tr -d '+°C')
    core2_temp=$(echo "$sensor_output" | awk '/Core 2:/ {print $3}' | tr -d '+°C')
    core3_temp=$(echo "$sensor_output" | awk '/Core 3:/ {print $3}' | tr -d '+°C')

    # Extract NVMe drive temperature
    nvme_temp=$(echo "$sensor_output" | awk '/Composite:/ {print $2}' | tr -d '+°C')

    # Extract fan speed
    fan_speed=$(echo "$sensor_output" | awk '/fan1:/ {print $2}' | tr -d 'RPM')

    # Extract voltage and current for the first adapter
    adapter1_voltage=$(echo "$sensor_output" | awk '/ucsi_source_psy_USBC000:002-isa-0000/,/curr1/ {if($1=="in0:"){print $2}}' | tr -d 'V')
    adapter1_current=$(echo "$sensor_output" | awk '/ucsi_source_psy_USBC000:002-isa-0000/,/curr1/ {if($1=="curr1:"){print $2}}' | tr -d 'A')

    # Extract voltage and current for the second adapter
    adapter2_voltage=$(echo "$sensor_output" | awk '/ucsi_source_psy_USBC000:001-isa-0000/,/curr1/ {if($1=="in0:"){print $2}}' | tr -d 'V')
    adapter2_current=$(echo "$sensor_output" | awk '/ucsi_source_psy_USBC000:001-isa-0000/,/curr1/ {if($1=="curr1:"){print $2}}' | tr -d 'A')

    # Extract battery voltage and current
    battery_voltage=$(echo "$sensor_output" | awk '/BAT0-acpi-0/,/curr1/ {if($1=="in0:"){print $2}}' | tr -d 'V')
    battery_current=$(echo "$sensor_output" | awk '/BAT0-acpi-0/,/curr1/ {if($1=="curr1:"){print $2}}' | tr -d 'uA')

    # Display the collected data
    echo "Processor Temperature: $processor_temp°C"
    echo "Core 0 Temperature: $core0_temp°C"
    echo "Core 1 Temperature: $core1_temp°C"
    echo "Core 2 Temperature: $core2_temp°C"
    echo "Core 3 Temperature: $core3_temp°C"
    echo "NVMe Temperature: $nvme_temp°C"
    echo "Fan Speed: $fan_speed RPM"
    echo "Adapter 1 Voltage: $adapter1_voltage V"
    echo "Adapter 1 Current: $adapter1_current A"
    echo "Adapter 2 Voltage: $adapter2_voltage V"
    echo "Adapter 2 Current: $adapter2_current A"
    echo "Battery Voltage: $battery_voltage V"
    echo "Battery Current: $battery_current uA"

    # Formulate the SQL insert query
    sql_insert="INSERT INTO system_metrics (
        processor_temp,
        core0_temp,
        core1_temp,
        core2_temp,
        core3_temp,
        nvme_temp,
        fan_speed,
        adapter1_voltage,
        adapter1_current,
        adapter2_voltage,
        adapter2_current,
        battery_voltage,
        battery_current
    ) VALUES (
        $processor_temp,
        $core0_temp,
        $core1_temp,
        $core2_temp,
        $core3_temp,
        $nvme_temp,
        $fan_speed,
        $adapter1_voltage,
        $adapter1_current,
        $adapter2_voltage,
        $adapter2_current,
        $battery_voltage,
        $battery_current
    );"

    docker exec mysql_master bash -c "export MYSQL_PWD=111; mysql -u root -e '$sql_insert' mydb"

    #echo $sql_insert
    echo ""

    sleep 1
done
