@echo off
::░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ input/output file names.
::░░  See http://icompile.eladkarako.com/ffmpeg-fixes-your-video-files/ For More Details. ░░
::░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ input/output file names.
set FILE_INPUT="%~1"
set FILE_OUTPUT="%~d1%~p1%~n1_fixed.mp4"
::▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
::░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ grab RAW data from the video file. FRAMERATE such as 23.937 will be trunc to 23. it is still OK for calculating GOP and KEYINT but the end framerate needs to be the same, so at the ffmpeg comand(s) we will use the FRAMERATE_STRING which capture the value "AS-IS".
for /f "tokens=*" %%a in ('ffprobe -i %FILE_INPUT% -v "error" -select_streams "v:0" -show_entries "stream=avg_frame_rate" -print_format "default=noprint_wrappers=1:nokey=1"') do (
  set /a FRAMERATE=%%a
  set    FRAMERATE_STRING=%%a
);
for /f "tokens=*" %%a in ('ffprobe -i %FILE_INPUT% -v "error" -select_streams "v:0" -show_entries "stream=bit_rate"       -print_format "default=noprint_wrappers=1:nokey=1"') do (
  set /a BITRATE=%%a
);
::▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
::░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ calculation uses [FRAMERATE] and [BITRATE] for best practices.
set /a GROUP_OF_PICTURE=2*%FRAMERATE%
set /a KEYINT=2*%FRAMERATE%
set /a BUFSIZE=%BITRATE%/3
::▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
::░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ [optional] reformat (to use KB instead of bits, will loose-precision).
set /a BITRATE=%BITRATE%/1000
set /a BUFSIZE=%BUFSIZE%/1000

set BITRATE=%BITRATE%k
set BUFSIZE=%BUFSIZE%k
::▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
::░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ [optional] OVERRIDE GOP: simulate INFRA mode (num of frames per key-frames). GOP is number of frames between keyframes.  Smaller number === more keyframes === streaming will recover faster on packets drop. will increase file size, and lower the overall ability to compress data, thus (much) bigger file-size (could be x3 times)
set /a GROUP_OF_PICTURE=1
::▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
::░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ [optional] OVERRIDE keyint values to 1 so every frame that is i-frame will be IDR. avoiding distortion, at a price of slightly bigger file-size.
set /a KEYINT=1
::▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
::░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ [optional] preset (slow=smaller file). ultrafast|veryslow
set PRESET=ultrafast
::▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
::░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ [optional] stuff you can add at the end.   This one limits the output to 5 seconds total (good for reviewing the overall quality)
::set ADDITIONAL=-t "5"
::▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
::░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ The FFMPEG (compiled) commands
set FFMPEG1=ffmpeg.exe -y -hide_banner -r "%FRAMERATE_STRING%" -ss "00:00:00.000" -i %FILE_INPUT% -pass 1 -f "mp4"   -ss "00:00:00.001" -c:v libx264 -r "%FRAMERATE_STRING%" -g "%GROUP_OF_PICTURE%" -intra-refresh "0" -forced-idr "1" -keyint_min %KEYINT% -x264opts "keyint=%KEYINT%:min-keyint=%KEYINT%:no-scenecut" -fflags "+genpts" -async "1" -vsync "2" -preset "%PRESET%" -crf "21" -crf_max "21" -profile:v "baseline" -level "3.0" -tune "zerolatency" -pix_fmt "yuv420p" -movflags "+faststart" -bt "5M" -b:v "%BITRATE%" -maxrate "%BITRATE%" -bufsize "%BUFSIZE%"  %ADDITIONAL%   -filter_complex "[0:v]setpts=PTS-STARTPTS[TAG]; [TAG]yadif=0:-1:0[TAG]; [TAG]setpts=PTS-STARTPTS[TAG]; [TAG]mpdecimate,setpts=N/FRAME_RATE/TB[TAG]; [TAG]setpts=PTS-STARTPTS[TAG]" -map "[TAG]"             NUL
set FFMPEG2=ffmpeg.exe    -hide_banner -r "%FRAMERATE_STRING%" -ss "00:00:00.000" -i %FILE_INPUT% -pass 2 -f "mp4"   -ss "00:00:00.001" -c:v libx264 -r "%FRAMERATE_STRING%" -g "%GROUP_OF_PICTURE%" -intra-refresh "0" -forced-idr "1" -keyint_min %KEYINT% -x264opts "keyint=%KEYINT%:min-keyint=%KEYINT%:no-scenecut" -fflags "+genpts" -async "1" -vsync "2" -preset "%PRESET%" -crf "21" -crf_max "21" -profile:v "baseline" -level "3.0" -tune "zerolatency" -pix_fmt "yuv420p" -movflags "+faststart" -bt "5M" -b:v "%BITRATE%" -maxrate "%BITRATE%" -bufsize "%BUFSIZE%"  %ADDITIONAL%   -filter_complex "[0:v]setpts=PTS-STARTPTS[TAG]; [TAG]yadif=0:-1:0[TAG]; [TAG]setpts=PTS-STARTPTS[TAG]; [TAG]mpdecimate,setpts=N/FRAME_RATE/TB[TAG]; [TAG]setpts=PTS-STARTPTS[TAG]" -map "[TAG]"   %FILE_OUTPUT%
::▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
::░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ [optional] on-screen information.
::echo ---------------------------------------------------
::echo FRAMERATE        =%FRAMERATE%
::echo FRAMERATE_STRING =%FRAMERATE_STRING%
::echo GROUP_OF_PICTURE =%GROUP_OF_PICTURE%
::echo KEYINT           =%KEYINT%
::echo BITRATE          =%BITRATE%
::echo BUFSIZE          =%BUFSIZE%
::echo ---------------------------------------------------
::echo FFMPEG1          =
::echo %FFMPEG1%
::echo.
::echo FFMPEG2          =
::echo %FFMPEG2%
::echo ---------------------------------------------------
::pause
::▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
::─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

%FFMPEG1% && %FFMPEG2%
pause





::░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ [optional] cleanup.
if exist ffmpeg2pass-*.log   del /f /q ffmpeg2pass-*.log         >nul
::▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

::Notes.
::*  storing each command in variable then executing it with "&&" makes sure the second-step will not run for no-reason, in-case the first step failed with any error code.
::*  The '-ss "00:00:00.000" -i... -ss "00:00:00.001"' helps ignore and rebuild the index. [a bit of a hack]
::*  forcing input framerate: preceding '-r "%FRAMERATE%"'.     forcing output --- just the same but "after the -i ..."
::*  "no-scenecut" - do not generate a key frame when there is a scene cut in the video. This keeps the key-frames-rate more consistant.
::*  The "-flags +genpts -async 1" is necessary to ensure that the concatenated audio segments will switch over at the same time as the video segment.
::*  "-keyint_min" minimum interval between IDR-frames (Instantaneous Decoder Refresh).    special type of I-frame in H.264. An IDR frame specifies that no frame after the IDR frame can reference any frame before it. This makes seeking the H.264 file easier and more responsive in the player.  default 25. by overriding the value to 1 every frame which is an i-frame will became a IDR frame (which is a type of i-frame), it prevents decoder from showing non-refreshed blockes with a slight file-size increase.
::*  -forced-idr helps the keyint setting.
::*  -intra-refresh "false" make never to use intra packets, but the most compatible IDR frames.
::*
