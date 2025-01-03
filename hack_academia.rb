TMP_MIN = 15
TMP_MAX = 30
TMP_FREQ = 440
HUM_MIN = 40
HUM_MAX = 70
HUM_FREQ = 880
WL_MIN = 50
WL_FREQ = 1320
PLAY_TIME = 50

class BLE
    def send_temp_humi_wl(temp, humi, wl)
        notify "THW,#{temp},#{humi},#{wl}"
    end
end

def main()
    if I2CDevice.mruby?
        LCD.text_size = 2
    end

    puts "Plant-Cultivation"
    sleep(1)

    gts = GroveTempHumiSensor.new
    gws = GroveWaterLevelSensor.new
    ble = BLE.new

    loop {
        tmp,hum = gts.read
        wl = gws.read
    
        if I2CDevice.mruby?
            LCD.clear
        end
    
        puts "Temperature:  #{tmp.round(2)}"
        puts "Humidity:     #{hum.round(2)}"
        puts "Water Level:  #{wl}"
        
        ble.send_temp_humi_wl(tmp.round(2), hum.round(2), wl)

        # 温度アラートバー
        LCD.fill_rect(30, 80, 20, 48, LCD::RED)
        LCD.fill_rect(30, 128, 20, 40, LCD::GREEN)
        LCD.fill_rect(30, 168, 20, 72, LCD::RED)
        # 温度バー
        LCD.fill_rect(50, 240 - tmp.round(2) * 4, 40, tmp.round(2) * 4, LCD::YELLOW)
        # 温度警告
        if tmp < TMP_MIN || tmp > TMP_MAX
            snd = Sound.new
            snd.tone(TMP_FREQ, PLAY_TIME)
        end 

        # 湿度アラートバー
        LCD.fill_rect(130, 80, 20, 48, LCD::RED)
        LCD.fill_rect(130, 128, 20, 32, LCD::GREEN)
        LCD.fill_rect(130, 160, 20, 80, LCD::RED)
        # 湿度バー
        LCD.fill_rect(150, 240 - hum.round(2) * 1.6, 40, hum.round(2) * 1.6, LCD::BLUE)
        # 湿度警告
        if hum < HUM_MIN || hum > HUM_MAX
            snd = Sound.new
            snd.tone(HUM_FREQ, PLAY_TIME)
        end

        # 水位アラートバー
        LCD.fill_rect(230, 80, 20, 80, LCD::GREEN)
        LCD.fill_rect(230, 160, 20, 80, LCD::RED)
        # 水位バー
        LCD.fill_rect(250, 240 - (wl / 5) * 8, 40, (wl / 5) * 8, LCD::CYAN)
        # 水位警告
        if wl < WL_MIN
            snd = Sound.new
            snd.tone(WL_FREQ, PLAY_TIME)
        end

        sleep(1)
    }
end

main