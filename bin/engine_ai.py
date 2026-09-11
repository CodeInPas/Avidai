import cv2
from ultralytics import YOLO
import os

def proses_video(video_path, target_fps, conf_threshold, temp_dir):
    """
    Fungsi pemrosesan AI utama yang dipanggil oleh Lazarus.
    Mengirimkan data real-time dengan format: DATA|Milidetik|Time|Objek|Path_Gambar
    """
    print(f"[INFO] Memulai analisis AI pada video: {os.path.basename(video_path)}", flush=True)
    
    if not os.path.exists(temp_dir):
        os.makedirs(temp_dir)
        
    model_path = os.path.join(os.path.dirname(__file__), 'yolov8n.pt')
    try:
        model = YOLO(model_path)
    except Exception as e:
        print(f"[ERROR] Gagal memuat model YOLO. Pastikan {model_path} ada. Detail: {e}", flush=True)
        return

    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        print(f"[ERROR] Gagal membuka video: {video_path}", flush=True)
        return
        
    video_fps = cap.get(cv2.CAP_PROP_FPS)
    if video_fps <= 0:
        print("[WARNING] Metadata FPS video tidak valid, menggunakan asumsi 25 FPS.", flush=True)
        video_fps = 25.0

    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    if total_frames <= 0:
        print("[WARNING] Jumlah total frame tidak terdeteksi, progress bar tidak akan presisi.", flush=True)
        total_frames = -1  
    
    target_fps = min(target_fps, video_fps)
    frame_skip = max(1, int(video_fps / target_fps))
    
    video_dir = os.path.dirname(video_path)
    video_name = os.path.splitext(os.path.basename(video_path))[0]
    output_txt_path = os.path.join(video_dir, f"result.txt")
    
    frame_count = 0
    
    try:
        with open(output_txt_path, 'w') as txt_file:
           # txt_file.write(f"Laporan Deteksi AI - {video_name}\n")
           # txt_file.write(f"Confidence Threshold: {conf_threshold*100}%\n")
           # txt_file.write("="*40 + "\n")
            
            while cap.isOpened():
                ret, frame = cap.read()
                if not ret:
                    break 
                    
                if frame_count % frame_skip == 0:
                    results = model(frame, conf=conf_threshold, verbose=False)
                    
                    if len(results[0].boxes) > 0:
                        
                        # --- KUNCI PERBAIKAN 1: BACA WAKTU ASLI DARI METADATA VIDEO (ANTI-VFR) ---
                        current_msec = cap.get(cv2.CAP_PROP_POS_MSEC)
                        if current_msec > 0:
                            timestamp_sec = current_msec / 1000.0
                        else:
                            timestamp_sec = frame_count / video_fps
                        
                        menit = int(timestamp_sec // 60)
                        detik = timestamp_sec % 60
                        waktu_format = f"{menit:02d}:{detik:05.2f}"
                        
                        # --- KUNCI PERBAIKAN 2: PAKSA NAMA FILE PERSIS DENGAN HITUNGAN LAZARUS ---
                        # Mengambil angka detik persis yang sama dengan yang tercetak di layar
                        detik_float = float(f"{detik:05.2f}")
                        millis_exact = int(round((menit * 60 + detik_float) * 1000))
                        
                        objek_list = []
                        for c in results[0].boxes.cls:
                            objek_list.append(model.names[int(c)])
                        obj_str = ", ".join(objek_list) 
                        
                        # Buat Gambar 
                        annotated_frame = results[0].plot(line_width=1, font_size=1) 
                        annotated_frame = cv2.resize(annotated_frame, (700, 300))

                        # Simpan gambar menggunakan millis_exact
                        snap_name = f"snap_{millis_exact}.jpg"
                        snap_path = os.path.join(temp_dir, snap_name)
                        cv2.imwrite(snap_path, annotated_frame)
                        
                        # Kirim & Tulis Data
                        print(f"DATA|{millis_exact}|{waktu_format}|{obj_str}|{snap_path}", flush=True)
                        txt_file.write(f"{waktu_format} - {obj_str}\n")
                        txt_file.flush() 
                        
                    if total_frames > 0:
                        persen = min(100.0, (frame_count / total_frames) * 100)
                    else:
                        persen = 0.0 
                    print(f"PROGRESS:{persen:.1f}", flush=True)
                    
                frame_count += 1
                
    except Exception as e:
        print(f"[ERROR] Terjadi kesalahan saat memproses: {e}", flush=True)
        
    cap.release()
    print("PROGRESS:100.0", flush=True)
    print(f"[INFO] Selesai! File laporan TXT disimpan di: {output_txt_path}", flush=True)

if __name__ == "__main__":
    print("Skrip ini dirancang untuk dijalankan melalui aplikasi Lazarus.")