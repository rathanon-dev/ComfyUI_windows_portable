@echo off
:: ===============================
:: Configuration Variables
:: ===============================
set "DOWNLOAD_DIR=%cd%\download"
set "URL_7ZR=https://www.7-zip.org/a/7zr.exe"
set "FILE_7ZR=%DOWNLOAD_DIR%\7zr.exe"

set "URL_COMFY=https://github.com/comfyanonymous/ComfyUI/releases/download/v0.3.43/ComfyUI_windows_portable_nvidia.7z"
set "FILE_COMFY=%DOWNLOAD_DIR%\ComfyUI_windows_portable_nvidia.7z"

set "URL_PYTHON_EXTENSION=https://raw.githubusercontent.com/rathanon-dev/ComfyUI_windows_portable/main/packet/python_3.12.10.7z"
set "PYTHON_EXTENSION=%DOWNLOAD_DIR%\python_3.12.10.7z"

set "URL_TRITON=https://raw.githubusercontent.com/rathanon-dev/ComfyUI_windows_portable/main/packet/triton-3.0.0-cp312-cp312-win_amd64.whl"
set "FILE_TRITON=%DOWNLOAD_DIR%\triton-3.0.0-cp312-cp312-win_amd64.whl"

set "URL_SAGE=https://github.com/woct0rdho/SageAttention/releases/download/v2.2.0-windows/sageattention-2.2.0+cu128torch2.7.1-cp312-cp312-win_amd64.whl"
set "FILE_SAGE=%DOWNLOAD_DIR%\sageattention-2.2.0+cu128torch2.7.1-cp312-cp312-win_amd64.whl"

set "TEMP_EXTRACT_DIR=%cd%\_temp_extract"
set "PYTHON_EMBEDED_DIR=%cd%\python_embeded"
set "COMFYUI_DIR=%cd%\ComfyUI"


GOTO MAIN
 

:: ฟังก์ชันต่างๆ ต้องอยู่หลัง :MAIN เพื่อให้ batch รู้จัก
:log
    setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
    set "msg=%~1"
    for /f "tokens=1-3 delims=:.," %%a in ("%time%") do (
        set "time_str=%%a:%%b:%%c"
    )
    echo [%date% %time_str%] %msg%
    endlocal & exit /b 0

:: ===============================
:: Function: log message with timestamp
:: ===============================
:log
    setlocal
    set "msg=%~1"
    for /f "tokens=1-3 delims=:.," %%a in ("%time%") do (
        set "time_str=%%a:%%b:%%c"
    )
    echo [%date% %time_str%] %msg%
    endlocal & exit /b 0

:: ===============================
:: Function: check and download a file if missing
:: Params: %1 = file path, %2 = url
:: ===============================
:check_and_download
    setlocal
    set "FILEPATH=%~1"
    set "FILEURL=%~2"

    if exist "%FILEPATH%" (
        call :log "File already exists: %FILEPATH%"
        endlocal & exit /b 0
    )

    call :log "Downloading from %FILEURL% ..."
    curl -L --retry 3 --retry-delay 5 "%FILEURL%" -o "%FILEPATH%"
    if errorlevel 1 (
        call :log "ERROR: Failed to download %FILEPATH%"
        endlocal & exit /b 1
    )
    call :log "Download successful: %FILEPATH%"
    endlocal & exit /b 0

:: ===============================
:: Function: Extract archive with 7zr.exe
:: Params: %1 = archive file path, %2 = output directory
:: ===============================
:extract_archive
    setlocal
    set "ARCHIVE=%~1"
    set "OUTDIR=%~2"

    if not exist "%ARCHIVE%" (
        call :log "ERROR: Archive file not found: %ARCHIVE%"
        endlocal & exit /b 1
    )

    if exist "%OUTDIR%" (
        rd /s /q "%OUTDIR%"
    )
    mkdir "%OUTDIR%"

    call :log "Extracting %ARCHIVE% to %OUTDIR% ..."
    "%FILE_7ZR%" x "%ARCHIVE%" -y -o"%OUTDIR%"
    if errorlevel 1 (
        call :log "ERROR: Extraction failed for %ARCHIVE%"
        endlocal & exit /b 1
    )

    call :log "Extraction successful."
    endlocal & exit /b 0

:: ===============================
:: Function: Move extracted ComfyUI files to working directory
:: ===============================
:move_comfyui_files
    setlocal
    set "EXTRACTED_DIR=%~1"

    if exist "%EXTRACTED_DIR%\ComfyUI_windows_portable" (
        call :log "Detected nested ComfyUI_windows_portable folder. Moving its contents..."
        robocopy "%EXTRACTED_DIR%\ComfyUI_windows_portable" "%cd%" /MOVE /E /NFL /NDL >nul
    ) else (
        call :log "Moving all contents from extracted folder..."
        robocopy "%EXTRACTED_DIR%" "%cd%" /MOVE /E /NFL /NDL >nul
    )

    rd /s /q "%EXTRACTED_DIR%"
    call :log "Cleanup after move complete."
    endlocal & exit /b 0

:: ===============================
:: Function: Setup ComfyUI
:: ===============================
:setup_comfyui
    setlocal

    if exist "%COMFYUI_DIR%" if exist "%PYTHON_EMBEDED_DIR%" if exist "%cd%\update" (
        call :log "ComfyUI and dependencies already installed. Skipping setup."
        endlocal & exit /b 0
    )

    call :check_and_download "%FILE_COMFY%" "%URL_COMFY%" || (
        call :log "ERROR: Downloading ComfyUI failed."
        endlocal & exit /b 1
    )

    call :extract_archive "%FILE_COMFY%" "%TEMP_EXTRACT_DIR%" || (
        call :log "ERROR: Extracting ComfyUI archive failed."
        endlocal & exit /b 1
    )

    call :move_comfyui_files "%TEMP_EXTRACT_DIR%"
    endlocal & exit /b 0

:: ===============================
:: Function: Extract Python Embedded
:: ===============================
:extract_python
    setlocal

    set "PYTHON_TEMP=%DOWNLOAD_DIR%\python_temp"
    if exist "%PYTHON_TEMP%" rd /s /q "%PYTHON_TEMP%"

    call :extract_archive "%PYTHON_EXTENSION%" "%PYTHON_TEMP%" || (
        call :log "ERROR: Extracting Python embedded archive failed."
        endlocal & exit /b 1
    )

    if not exist "%PYTHON_TEMP%\python_3.12.10" (
        call :log "ERROR: Expected Python folder not found: %PYTHON_TEMP%\python_3.12.10"
        endlocal & exit /b 1
    )

    call :log "Copying Python embedded files..."
    robocopy "%PYTHON_TEMP%\python_3.12.10" "%PYTHON_EMBEDED_DIR%" /E /XO /NFL /NDL >nul

    rd /s /q "%PYTHON_TEMP%"
    call :log "Python extraction and copy complete."
    endlocal & exit /b 0

:: ===============================
:: Function: Install Python packages (pip)
:: ===============================
:install_python_packages
    setlocal

    set "PYTHON_EXE=%PYTHON_EMBEDED_DIR%\python.exe"
    if not exist "%PYTHON_EXE%" (
        call :log "ERROR: Python executable not found at %PYTHON_EXE%"
        endlocal & exit /b 1
    )

    call :log "Upgrading pip..."
    "%PYTHON_EXE%" -m pip install --upgrade pip || (
        call :log "ERROR: Failed to upgrade pip."
        endlocal & exit /b 1
    )

    call :log "Installing Triton package..."
    "%PYTHON_EXE%" -m pip install -U "triton-windows<3.4" || (
        call :log "ERROR: Failed to install Triton package."
        endlocal & exit /b 1
    )

    call :log "Installing SageAttention package..."
    "%PYTHON_EXE%" -m pip install "%FILE_SAGE%" || (
        call :log "ERROR: Failed to install SageAttention package."
        endlocal & exit /b 1
    )

    call :log "Python packages installed successfully."
    endlocal & exit /b 0

:: ===============================
:: Function: Install additional custom nodes via git
:: Params: %1 = git URL, %2 = optional custom folder name
:: ===============================
:install_custom_node
    setlocal ENABLEDELAYEDEXPANSION
    set "URLGIT=%~1"
    set "CUSTOM_NODE_NAME=%~2"

    if not defined CUSTOM_NODE_NAME (
        for %%A in ("%URLGIT%") do (
            for /f "tokens=1 delims=." %%B in ("%%~nA") do set "CUSTOM_NODE_NAME=%%B"
        )
    )

    set "PYTHON_EXE=%PYTHON_EMBEDED_DIR%\python.exe"
    if not exist "%PYTHON_EXE%" (
        call :log "ERROR: Python executable not found at %PYTHON_EXE%"
        endlocal & exit /b 1
    )

    if not exist "%COMFYUI_DIR%" (
        call :log "ERROR: ComfyUI directory not found at %COMFYUI_DIR%"
        endlocal & exit /b 1
    )

    call :log "Installing custom node '%CUSTOM_NODE_NAME%' from %URLGIT%..."
    "%PYTHON_EXE%" -m pip install --upgrade pip --no-warn-script-location || (
        call :log "ERROR: Failed to upgrade pip for custom node."
        endlocal & exit /b 1
    )
    "%PYTHON_EXE%" -m pip install gitpython --no-warn-script-location || (
        call :log "ERROR: Failed to install gitpython."
        endlocal & exit /b 1
    )

    "%PYTHON_EXE%" -c "import git; git.Repo.clone_from(r'%URLGIT%', r'%COMFYUI_DIR%\\custom_nodes\\%CUSTOM_NODE_NAME%')" || (
        call :log "ERROR: Failed to clone git repository."
        endlocal & exit /b 1
    )

    if exist "%COMFYUI_DIR%\custom_nodes\%CUSTOM_NODE_NAME%\requirements.txt" (
        "%PYTHON_EXE%" -m pip install -r "%COMFYUI_DIR%\custom_nodes\%CUSTOM_NODE_NAME%\requirements.txt" --no-warn-script-location || (
            call :log "ERROR: Failed to install custom node requirements."
            endlocal & exit /b 1
        )
    )

    call :log "Custom node '%CUSTOM_NODE_NAME%' installed successfully."
    endlocal & exit /b 0

:: ===============================
:: Function: Check NVIDIA CUDA driver presence
:: ===============================
:check_cuda_driver
    setlocal
    call :log "Checking for NVIDIA CUDA Driver..."
    where nvidia-smi >nul 2>&1
    if errorlevel 1 (
        call :log "ERROR: NVIDIA CUDA Driver not found. Please install the latest NVIDIA driver with CUDA support."
        endlocal & exit /b 1
    )
    call :log "NVIDIA CUDA Driver found."
    nvidia-smi
    endlocal & exit /b 0

:: ===============================
:: Function: Check and install required programs via winget
:: Params: %1 = program name, %2 = install command
:: ===============================
:check_installation
    setlocal
    set "program_name=%~1"
    set "install_command=%~2"

    call :log "Checking program: %program_name% ..."
    where "%program_name%" >nul 2>nul
    if errorlevel 1 (
        call :log "Program '%program_name%' not found. Installing..."
        %install_command%
        if errorlevel 1 (
            call :log "ERROR: Failed to install '%program_name%'. Please check your system configuration."
            endlocal & exit /b 1
        )
        call :log "Program '%program_name%' installed successfully."
    ) else (
        call :log "Program '%program_name%' is already installed."
    )
    endlocal & exit /b 0

:update_run_bat
    setlocal

    set "filename=run_nvidia_gpu_fast_fp16_accumulation.bat"

    if exist "%filename%" (
        call :log "Found existing %filename%, deleting..."
        del "%filename%"
    ) else (
        call :log "%filename% does not exist, creating new..."
    )

    call :log "Writing new commands to %filename% ..."
    (
        echo .\python_embeded\python.exe -s ComfyUI\main.py --windows-standalone-build --fast fp16_accumulation --use-sage-attention
        echo pause
    ) > "%filename%"

    call :log "%filename% updated successfully."

    endlocal & exit /b 0


:: ===============================
:: Main script execution starts here
:: ===============================
:MAIN
	echo ComfyUI_windows_portable + triton + sageattention 2
	call :log "ComfyUI_windows_portable + triton + sageattention 2!"

    :: Ensure download directory exists
    if not exist "%DOWNLOAD_DIR%" mkdir "%DOWNLOAD_DIR%"

    call :check_cuda_driver || goto :error_exit

    call :check_installation git "winget install --id=Git.Git -e --source winget" || goto :error_exit
    call :check_installation ffmpeg "winget install --id=Gyan.FFmpeg -e --source winget" || goto :error_exit
    call :check_installation curl "winget install --id=cURL.cURL -e --source winget" || goto :error_exit
    call :check_and_download "%FILE_7ZR%" "%URL_7ZR%" || goto :error_exit
    call :check_and_download "%PYTHON_EXTENSION%" "%URL_PYTHON_EXTENSION%" || goto :error_exit
    call :check_and_download "%FILE_TRITON%" "%URL_TRITON%" || goto :error_exit
    call :check_and_download "%FILE_SAGE%" "%URL_SAGE%" || goto :error_exit

    call :setup_comfyui || goto :error_exit
    call :extract_python || goto :error_exit
    call :install_python_packages || goto :error_exit

    :: Install custom nodes
    call :install_custom_node "https://github.com/ltdrdata/ComfyUI-Manager" || goto :error_exit
    call :install_custom_node "https://github.com/Flow-two/flow2-wan-video" || goto :error_exit
    call :install_custom_node "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite" || goto :error_exit
    call :install_custom_node "https://github.com/crystian/ComfyUI-Crystools" || goto :error_exit
    call :update_run_bat || goto :error_exit

    echo.
    call :log "=============================="
    call :log "Extraction and installation complete!"
    call :log "Press any key to exit..."
    call :log "=============================="
    pause >nul

    exit /b 0

:error_exit
    echo.
    call :log "Script terminated due to errors. Please review messages above."
    pause >nul
    exit /b 1
