Write-Host "                  ___                       ___       ___                       " -ForegroundColor DarkGray
Write-Host "                 /\  \          ___        /\__\     /\__\		                " -ForegroundColor DarkGray
Write-Host "                 \:\  \        /\  \      /:/  /    /:/  /		                " -ForegroundColor DarkGray
Write-Host "                  \:\  \       \:\  \    /:/  /    /:/  /		                " -ForegroundColor DarkGray
Write-Host "                   \:\  \      /::\__\  /:/  /    /:/  /  ___ 	                " -ForegroundColor DarkGray
Write-Host "             _______\:\__\  __/:/\/__/ /:/__/    /:/__/  /\__\	                " -ForegroundColor DarkGray
Write-Host "             \::::::::/__/ /\/:/  /    \:\  \    \:\  \ /:/  /	                " -ForegroundColor DarkGray
Write-Host "              \:\~~\~~     \::/__/      \:\  \    \:\  /:/  /	                " -ForegroundColor DarkGray
Write-Host "               \:\  \       \:\__\       \:\  \    \:\/:/  /	                " -ForegroundColor DarkGray
Write-Host "                \:\__\       \/__/        \:\__\    \::/  /		                " -ForegroundColor DarkGray
Write-Host "                 \/__/                     \/__/     \/__/		                " -ForegroundColor DarkGray
Write-Host "                                                                                " -ForegroundColor DarkGray
Write-Host "    Copyright (C) 2020 ZiLu https://github.com/zhongzilu/ADB-Tools-Shell.git 	" -ForegroundColor DarkGray
Write-Host "                                                                                " -ForegroundColor DarkGray
Write-Host "                        Welcome to ADB Tools Shell v1.0                         " -ForegroundColor DarkGray
Write-Host "                                                                                " -ForegroundColor DarkGray

function List_Devices
{
    $loop = $true
    Do
    {
        $target = ./adb.exe devices

        if ($target.count -gt 2)
        {
            Write-Host " " -ForegroundColor DarkMagenta
            Write-Host "-------找到以下设备--------" -ForegroundColor Cyan
            Write-Host " " -ForegroundColor DarkMagenta
            Write-Host "[0]返回.." -ForegroundColor Green

            $count = 0
            for($i = 1; $i -le $target.count; $i++)
            {
                if (($target[$i] -ne "") -and ($null -ne $target[$i]))
                {
                    $count += 1
                    "[" + $i + "]" + $target[$i] | Write-Host -ForegroundColor Green
                }
            }

            Write-Host " " -ForegroundColor DarkMagenta

            Do
            {
                $choice = Read-Host "请输入设备编号"
                if ($choice -eq 0)
                {
                    $loop = $false
                    break
                }
            } while ($choice -notin 1..$count)

            if ($loop -ne $true)
            {
                return
            }

            Func_Menu(($target[$choice].split())[0])
        }
        else
        {
            Write-Host "没有找到任何设备！" -ForegroundColor Red
            break
        }
    } while ($loop)
}

function Network_Devices
{
    Write-Host " " -ForegroundColor DarkMagenta
    Write-Host ("[Tip: 空内容则返回上级菜单]") -ForegroundColor DarkGray
    Write-Host " " -ForegroundColor DarkMagenta
    $ip = Read-Host "请输入远程设备IP和端口号, 格式：[ip:port]"

    if (($null -eq $ip) -or ("" -eq $ip))
    {
        return
    }

    Write-Host "正在连接，请稍后..." -ForegroundColor DarkGray

    $con = ./adb.exe connect $ip
    Write-Host $con
    if (($con -like "cannot*") -or ($con -like "failed*"))
    {
        return Network_Devices
    }

    List_Devices
}

function Func_Menu($device)
{
    $loop = $true
    $menu = "返回..", "远程桌面", "安装App", "启动App", "强制结束App", "发送文件", "拉取文件", "查看目录文件", "获取Root", "查看所有App",
    "发送广播", "Logcat", "屏幕录像", "重启设备"
    Do
    {
        Write-Host " " -ForegroundColor DarkMagenta
        Write-Host "-------功能菜单--------" -ForegroundColor White
        Write-Host " " -ForegroundColor DarkMagenta

        for($i = 0; $i -lt $menu.count; $i++)
        {
            "[" + $i + "]" + $menu[$i] | Write-Host -ForegroundColor Green
        }

        Do
        {
            Write-Host "---------功能选择----------" -ForegroundColor DarkMagenta
            $choice = Read-Host "选择"

            if ($choice -eq 0)
            {
                $loop = $false
                break
            }

            $check = $choice -notin 0..($menu.Count - 1)
            if ($check)
            {
                Write-Host "输入错误" -ForegroundColor Red
                continue
            }

            switch ($choice)
            {
                1{
                    Remote_Desktop($device)
                }
                2{
                    Install_App($device)
                }
                3{
                    Invoke_App($device)
                }
                4{
                    Kill_App($device)
                }
                5{
                    Send_File($device)
                }
                6{
                    Pull_File($device)
                }
                7{
                    List_File($device)
                }
                8{
                    Root_Device($device)
                }
                9{
                    List_Packages($device)
                }
                10{
                    Send_Broadcast($device)
                }
                11{
                    Logcat($device)
                }
                12{
                    Screen_Record($device)
                }
                13{
                    $loop = $false
                    ./adb.exe -s $device shell reboot
                }
            }

        } while ($check -and $loop)

    } while (($choice -ne 0) -and $loop)
}

function Remote_Desktop($device)
{
    Start-Process -FilePath "./scrcpy.exe" -ArgumentList "-s $device"
}

function Screen_Record($device)
{
    $ts = Get-Date -Format 'yyyyMMddHHmmss'
    Start-Process -FilePath "./scrcpy.exe" -ArgumentList "-s $device -r $ts.mp4"
}

function Install_App($device)
{
    Write-Host " " -ForegroundColor DarkMagenta
    Write-Host "[注意：文件名不能包含空格]" -ForegroundColor Yellow
    $apk = Read-Host "请将要安装的Apk文件拖放到这里"

    ./adb.exe -s $device install -r "$apk"
}

function Invoke_App($device)
{
    $menu = "返回..", "系统设置", "其他App"
    Do
    {
        Write-Host " " -ForegroundColor DarkMagenta
        for($i = 0; $i -lt $menu.count; $i++)
        {
            "[" + $i + "]" + $menu[$i] | Write-Host -ForegroundColor Green
        }

        Write-Host "---------功能选择----------" -ForegroundColor DarkMagenta
        $choice = Read-Host "选择"

        $check = $choice -notin 0..($menu.Count - 1)
        if ($check)
        {
            Write-Host "输入错误" -ForegroundColor Red
            continue
        }

        switch ($choice)
        {
            1{
                $res = ./adb.exe -s $device shell am start -a android.settings.SETTINGS
                if ($res -like "Starting*")
                {
                    Write-Host "启动成功" -ForegroundColor DarkGray
                }
                else
                {
                    Write-Host "启动失败或不存在该应用" -ForegroundColor Yellow
                }
            }
            2{
                $pack = Read-Host "请输入应用包名"
                invoke($pack)
            }
        }

    } while ($choice -ne 0)
}

function invoke($packageName)
{
    #./adb.exe -s $device shell am start -a android.intent.action.MAIN -n $packageName
    $res = ./adb.exe -s $device shell monkey -p $packageName -c android.intent.category.LAUNCHER 1
    if ($res -like "*No activities*")
    {
        Write-Host "启动失败或不存在该应用" -ForegroundColor Yellow
        return $false
    }
    else
    {
        Write-Host "启动成功" -ForegroundColor DarkGray
        return $true
    }
}

function Kill_App($device)
{
    Write-Host " " -ForegroundColor DarkMagenta
    $package = Read-Host "请输入应用包名"
    if ("" -eq $package)
    {
        return
    }

    ./adb.exe -s $device shell am force-stop $package
}

function Send_File($device)
{
    $choice = Choose_Path
    if (($null -eq $choice) -or ("" -eq $choice))
    {
        return
    }

    Write-Host " " -ForegroundColor DarkMagenta
    Write-Host "[注意：文件名不能包含空格,且文件所在路径不能存在中文目录]" -ForegroundColor Yellow
    $file = Read-Host "请将文件拖放到这里"

    Write-Host $file
    ./adb.exe -s $device push "$file" $choice
}

function Choose_Path
{
    Write-Host " " -ForegroundColor DarkMagenta
    Write-Host "-------常用目录---------"
    Write-Host " " -ForegroundColor DarkMagenta

    $menu = "返回..", "用户目录", "Download", "其他"

    for($i = 0; $i -lt $menu.count; $i++)
    {
        "[" + $i + "]" + $menu[$i] | Write-Host -ForegroundColor Green
    }

    Write-Host "---------目录选择----------" -ForegroundColor DarkMagenta
    $choice = Read-Host "选择"
    switch ($choice)
    {
        1{
            return "/storage/emulated/legacy/"
        }
        2{
            return "/storage/emulated/legacy/Download/"
        }
        3{
            Write-Host " " -ForegroundColor DarkMagenta
            $path = Read-Host "请输入完整的访问路径"
            return $path
        }
    }

    return $null
}

function Pull_File($device)
{
    $choice = Choose_Path
    if (($null -eq $choice) -or ("" -eq $choice))
    {
        return
    }

    Write-Host " " -ForegroundColor DarkMagenta
    $file = Read-Host "请输入文件名"

    ./adb.exe -s $device pull "$choice/$file" ./
}

function List_File($device)
{
    $path = Choose_Path
    if (($null -eq $path) -or ("" -eq $path))
    {
        return
    }

    ./adb.exe -s $device shell ls -ls $path
}

function Root_Device($device)
{
    ./adb.exe -s $device root
    ./adb.exe -s $device remount
}

function List_Packages($device)
{
    ./adb.exe -s $device shell pm list packages
}

function Send_Broadcast($device)
{
    Write-Host " " -ForegroundColor DarkMagenta
    $action = Read-Host "[必填]Action"

    Write-Host " " -ForegroundColor DarkMagenta
    $category = Read-Host "[可选]Category"

    Write-Host " " -ForegroundColor DarkMagenta
    $component = Read-Host "[可选]Component"

    Write-Host " " -ForegroundColor DarkMagenta
    $parmas = Read-Host "[可选]Params"

    if (($null -eq $action) -or ("" -eq $action))
    {
        Write-Host "Action不能为空" -ForegroundColor Red
        return
    }

    if (($null -ne $category) -and ("" -ne $category))
    {
        $action += " -c $category"
    }

    if (($null -ne $component) -and ("" -ne $component))
    {
        $action += " -n $component"
    }

    if (($null -ne $parmas) -and ("" -ne $parmas))
    {
        $action += " $parmas"
    }

    ./adb.exe -s $device shell am broadcast -a $action
}

function Logcat($device)
{
    Write-Host " " -ForegroundColor DarkMagenta
    $keyword = Read-Host "请输入搜索关键字"

    $c = "./adb.exe -s $device logcat D |Where-Object { `$_` -like `"*$keyword*`" }"
    Invoke-Expression "cmd /c start powershell -Command {$c} -NoProfile -NoExit"
}

function Main
{
    $menu = "", "本地连接模式", "远程连接模式", "kill-server"
    Do
    {
        Write-Host " " -ForegroundColor DarkMagenta
        Write-Host "-------功能菜单--------" -ForegroundColor White
        Write-Host " " -ForegroundColor DarkMagenta

        for($i = 1; $i -lt $menu.count; $i++)
        {
            "[" + $i + "]" + $menu[$i] | Write-Host -ForegroundColor Green
        }
        Write-Host ("[" + $QUIT + "]退出") -ForegroundColor Green

        Write-Host "---------功能选择----------" -ForegroundColor DarkMagenta
        $choice = Read-Host "选择"

        if ($choice -eq 1)
        {
            List_Devices
        }
        elseif ($choice -eq 2)
        {
            Network_Devices
        }
        elseif ($choice -eq 3)
        {
            ./adb.exe kill-server
        }
        elseif ($choice -eq $QUIT)
        {
            ./adb.exe kill-server
        }
    } while ( $choice -ne $QUIT)
}

$global:QUIT = "q"

Main