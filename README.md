# ComfyUI_windows_portable  + triton + sageattention 2  
## การติดตั้งและการใช้งาน
### ข้อกำหนดเบื้องต้น
 **ระบบปฏิบัติการ:** Windows (ทดสอบบน Windows 10/11)
1. **ข้อกำหนดด้านฮาร์ดแวร์:**
   - การ์ดกราฟิก NVIDIA ที่รองรับ CUDA และ VRAM 12GB+ up (RTX3XXX-RTX5XXX)
   - RAM ขั้นต่ำ 16GB
   - SSD ขั้นต่ำ 512GB 
2. **ข้อกำหนดด้านซอฟต์แวร์:**
   - Git
   - 7zip
   - Python 3.12 (Python 3.12.10 extensions)
   - PIP 25.0
   - CUDA 12.8
   - C compiler install [Visual Studio Build Tools](https://aka.ms/vs/17/release/vs_BuildTools.exe) , I recommend to install MSVC and Windows SDK.
   - Triton-Windows [Check your GPU model. Technically they're categorized by 'compute capability](https://github.com/woct0rdho/triton-windows?tab=readme-ov-file#1-gpu)
   - [SageAttention-Windows](https://github.com/woct0rdho/SageAttention)
   - vcredist vcredist is required (also known as 'Visual C++ Redistributable for Visual Studio 2015-2022', msvcp140.dll, vcruntime140.dll), because libtriton.pyd is compiled by MSVC. Install it from
    [https://aka.ms/vs/17/release/vc_redist.x64.exe](https://aka.ms/vs/17/release/vc_redist.x64.exe)

> [!WARNING] 
> **คำแนะนำ วิธีการติดตั้งโดยละเอียด [Triton-Windows](https://github.com/woct0rdho/triton-windows)**

### ขั้นตอนการติดตั้งและตั้งค่า
1. **สร้างโฟลเดอร์สำหรับการติดตั้ง ComfyUI auto install for Windows:**
   สร้างโฟลเดอร์เปล่าเพื่อจัดเก็บโปรเจค
   ```bash
   mkdir name_folder
   ```

2. **โคลน Repository:**
   โคลน **FaceFusion auto install for Windows** repository ถ้ายังไม่ได้ทำ:
   ```bash
   git clone https://github.com/rathaon-dev/ComfyUI_windows_portable name_folder
   ```

3. **รันสคริปต์การติดตั้ง:**
   ดาวน์โหลดสคริปต์และรันจาก `cmd` (Command Prompt) สคริปต์จะ:
   - add  python extension  12.10
   - add Triton for window triton-windows-3.3
   - add Sageattention-2.2.0+cu128torch2.7.1-cp312-cp312-win_amd64
   - add ComfyUI-Manager
      * flow2-wan-video 
      * ComfyUI-VideoHelperSuite
      * ComfyUI-Crystools
    - and use --use-sage-attention
      
   รันสคริปต์โดยการดับเบิลคลิกไฟล์ `.bat` หรือรันจาก Command Prompt:
   ```bash
    auto_install_ComfyUI.bat
   ```
   
## คำขอบคุณ

โครงการนี้พัฒนาขึ้นโดยใช้พื้นฐานจาก repository ของ **ComfyUI** ที่พัฒนาโดย [ComfyUI](https://github.com/comfyanonymous/ComfyUI) ขอบคุณผู้ร่วมพัฒนาใน repository ดั้งเดิมสำหรับการทำงานที่ยอดเยี่ยม

- [ComfyUI](https://github.com/comfyanonymous/ComfyUI)
- [Triton-Windows](https://github.com/woct0rdho/triton-windows)
- [SageAttention-Windows](https://github.com/woct0rdho/SageAttention)

กรุณาเยี่ยมชม repository ดั้งเดิมสำหรับเอกสารเพิ่มเติม, การอัพเดต, และการสนับสนุน
## Contact
- 📧 Email: [rathanon.dev@gmail.com](mailto:rathanon.dev@gmail.com)
- 🌐 GitHub: [github.com/rathanon-dev](https://github.com/rathanon-dev)
- 🔗 LinkedIn: [ratanon](www.linkedin.com/in/ratanon-sangrungsawang-233348327)
