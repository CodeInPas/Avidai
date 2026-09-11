unit main_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin,
  PasLibVlcPlayer, ComCtrls, ExtCtrls, Buttons, Menus, PythonEngine,
  PythonGUIInputOutput, XelUI.Widgets, DTThemedGauge, IdThreadComponent,
  PasLibVlcPlayerUnit, Math;

type

  { TMainForm }

  TMainForm = class(TForm)
    btnSee: TSpeedButton;
    BtnPilihVideo: TButton;
    BtnPlay: TButton;
    BtnProses: TButton;
    btnStop: TSpeedButton;
    dtgauge: TDTThemedGauge;
    EditFilter: TEdit;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    mnMyPortofolio: TMenuItem;
    mnApp: TMenuItem;
    Panel1: TPanel;
    btnPause: TSpeedButton;
    Panel6: TPanel;
    Panel7: TPanel;
    Separator1: TMenuItem;
    tbsProgress: TTabSheet;
    tmPlaySnapshot: TTimer;
    tmProgress: TTimer;
    trbPlay: TTrackBar;
    TrdProcess: TIdThreadComponent;
    ImageSnapshot: TImage;
    Label2: TLabel;
    Label3: TLabel;
    LblConf: TLabel;
    ListBoxLog: TListBox;
    Memo1: TMemo;
    OpenDialog1: TOpenDialog;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    pgMain: TPageControl;
    Panel2: TPanel;
    spVLCPlay: TSpeedButton;
    spVLCPause: TSpeedButton;
    spVLCSetop: TSpeedButton;
    SpinFPS: TFloatSpinEdit;
    TabSheet3: TTabSheet;
    trvlc: TTrackBar;
    TrackConf: TTrackBar;
    VlcPlayer1: TPasLibVlcPlayer;
    tbsImage: TTabSheet;
    tbsVideo: TTabSheet;
    ProgressBar1: TProgressBar;
    PythonEngine1: TPythonEngine;
    PythonGUIInputOutput1: TPythonGUIInputOutput;
    procedure BtnPilihVideoClick(Sender: TObject);
    procedure BtnPlayClick(Sender: TObject);
    procedure BtnProsesClick(Sender: TObject);
    procedure btnPauseClick(Sender: TObject);
    procedure btnSeeClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure EditFilterChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ImageSnapshotDblClick(Sender: TObject);
    procedure ListBoxLogDblClick(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure PythonGUIInputOutput1SendData(Sender: TObject; const Data: string);
    procedure spVLCPauseClick(Sender: TObject);
    procedure spVLCPlayClick(Sender: TObject);
    procedure spVLCSetopClick(Sender: TObject);
    procedure tmPlaySnapshotTimer(Sender: TObject);
    procedure tmProgressTimer(Sender: TObject);
    procedure TrackConfChange(Sender: TObject);
    procedure TrdProcessRun(Sender: TIdThreadComponent);
    procedure TrdProcessTerminate(Sender: TIdThreadComponent);
    procedure trvlcChange(Sender: TObject);
    procedure trvlcClick(Sender: TObject);
    procedure VlcPlayer1MediaPlayerPlaying(Sender: TObject);
    procedure VlcPlayer1MediaPlayerPositionChanged(Sender: TObject;
      Posisi: Single);
  private
    VideoPath: string;
    IsPythonLoaded: Boolean;   // <--- TAMBAHKAN BARIS INI
    OutputBuffer: string;      // <--- TAMBAHKAN BARIS INI (Wadah penampung teks)
    // StringList tersembunyi untuk menyimpan data mentah
    RawLogs: TStringList;
    RawMillis: TStringList;
    RawSnapshots: TStringList;

    procedure BersihkanFolderTemp;
    procedure TulisLog(const Pesan: string);
    procedure LoadFileTxtKeListBox(const FilePath: string);
    procedure DoProcess;
    procedure PlayMe(Posisi:Int64);
  public

  end;

var
  MainForm: TMainForm;
  i : integer = 0 ;
  stop : boolean = false;
  MiliDetik:Int64  ;
implementation

{$R *.lfm}

{ TMainForm }

// -------------------------------------------------------------------
// 1. INISIALISASI & PEMBERSIHAN
// -------------------------------------------------------------------
procedure TMainForm.FormCreate(Sender: TObject);
begin
  tbsImage.Show;
  IsPythonLoaded := False; // <--- TAMBAHKAN BARIS INI
  // Mencegah Lazarus crash akibat kalkulasi internal AI (PyTorch/OpenCV)
  SetExceptionMask([exInvalidOp, exDenormalized, exZeroDivide, exOverflow, exUnderflow, exPrecision]);

  // --- PERBAIKAN KOMUNIKASI PYTHON KE LAZARUS ---
  // Memaksa Lazarus menerima teks utuh per baris, bukan potongan byte

  PythonGUIInputOutput1.RawOutput := True;
  PythonGUIInputOutput1.UnicodeIO := True;

  // Inisialisasi memori penyimpan data
  RawLogs := TStringList.Create;
  RawMillis := TStringList.Create;
  RawSnapshots := TStringList.Create;

  // Konfigurasi Path VLC Portabel
  VlcPlayer1.VLC.Path := ExtractFilePath(Application.ExeName) + 'vlc_libs\';

  // Set nilai default Slider (Confidence 50%)
  TrackConf.Position := 50;
  TrackConfChange(Self);

  // Bersihkan folder snapshot sisa pemrosesan sebelumnya
 // BersihkanFolderTemp;
 LoadFileTxtKeListBox(ExtractFilePath(Application.ExeName) + 'result.txt' );

  if ListBoxLog.Items.Count > 0 then
    begin
      ListBoxLog.ItemIndex := 0; // Menyeleksi item pada baris pertama
       ListBoxLogDblClick(Sender);
    end;


end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  // Mencegah memory leak
  RawLogs.Free;
  RawMillis.Free;
  RawSnapshots.Free;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin

end;

procedure TMainForm.ImageSnapshotDblClick(Sender: TObject);
begin

end;

procedure TMainForm.PlayMe(Posisi:Int64);
begin

if VideoPath <> '' then
  begin
    VlcPlayer1.stop;
    tmPlaySnapshot.Enabled:=false;
    if not VlcPlayer1.IsPlay then
    begin
      VlcPlayer1.Play(WideString(VideoPath));
      VlcPlayer1.SetVideoPosInMs(Posisi);
      Sleep(1000);
      VlcPlayer1.Pause();
      tbsVideo.Show;
    end;
  end;


end;

procedure TMainForm.BersihkanFolderTemp;
var
  TempDir: string;
  SR: TSearchRec;
begin
  TempDir := ExtractFilePath(Application.ExeName) + 'temp_snapshots\';
  if not DirectoryExists(TempDir) then
    CreateDir(TempDir)
  else
  begin
    // Hapus semua file .jpg di dalam folder
    if FindFirst(TempDir + '*.jpg', faAnyFile, SR) = 0 then
    begin
      repeat
        DeleteFile(TempDir + SR.Name);
      until FindNext(SR) <> 0;
      FindClose(SR);
    end;
  end;
end;

// -------------------------------------------------------------------
// 2. KONTROL ANTARMUKA (UI)
// -------------------------------------------------------------------
procedure TMainForm.TrackConfChange(Sender: TObject);
begin
  // Update teks label saat slider digeser
  LblConf.Caption := 'Akurasi (Confidence): ' + IntToStr(TrackConf.Position) + '%';
end;

procedure TMainForm.TrdProcessRun(Sender: TIdThreadComponent);
begin
  DoProcess;
end;

procedure TMainForm.TrdProcessTerminate(Sender: TIdThreadComponent);
begin
  tmProgress.Enabled:=false;
  I := 0;
  dtgauge.Position:=0;
  tbsImage.show;
end;

procedure TMainForm.trvlcChange(Sender: TObject);
begin

end;

procedure TMainForm.trvlcClick(Sender: TObject);
begin
   VlcPlayer1.SetVideoPosInPercent(trvlc.Position);
end;

procedure TMainForm.VlcPlayer1MediaPlayerPlaying(Sender: TObject);
begin

end;

procedure TMainForm.VlcPlayer1MediaPlayerPositionChanged(Sender: TObject;
  posisi: Single);
begin
    trvlc.Position:= Trunc(VlcPlayer1.GetVideoPosInPercent);
end;

procedure TMainForm.BtnPilihVideoClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    VideoPath := OpenDialog1.FileName;
    RawLogs.Add('Video siap: ' + ExtractFileName(VideoPath));
    RawMillis.Add('');
    RawSnapshots.Add('');

    tbsVideo.Show;
    if VlcPlayer1.IsPlay() then VlcPlayer1.Stop(1000);
    VlcPlayer1.Play(VideoPath);
  end;
end;

procedure TMainForm.BtnPlayClick(Sender: TObject);
begin

  if ListBoxLog.ItemIndex = -1 then Exit;
  stop := false;
  tmPlaySnapshot.Interval:= trbPlay.Position * 100;
  tmPlaySnapshot.Enabled:=true;

end;

procedure TMainForm.BtnProsesClick(Sender: TObject);
begin
   if MessageDlg('Mulai Proses', 'Apakah Anda Akan Memulai Proses Deteksi',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      tbsProgress.Show;
      TrdProcess.Active:=true;
      tmProgress.Enabled:=true;
    end;
end;

procedure TMainForm.btnPauseClick(Sender: TObject);
begin
  stop := true;
  ListBoxLog.ItemIndex:=i;
end;

procedure TMainForm.btnSeeClick(Sender: TObject);
begin
  if VideoPath<>'' then
       PlayMe(MiliDetik);
end;

procedure TMainForm.btnStopClick(Sender: TObject);
begin
  stop := True;
  i := 0;
  ListBoxLog.ItemIndex:=0;
end;



// -------------------------------------------------------------------
// 3. FITUR PENCARIAN (FILTERING)
// -------------------------------------------------------------------
procedure TMainForm.EditFilterChange(Sender: TObject);
var
  i: Integer;
  KataKunci: string;
begin
  ListBoxLog.Clear;
  KataKunci := LowerCase(Trim(EditFilter.Text));

  for i := 0 to RawLogs.Count - 1 do
  begin
    if (KataKunci = '') or (Pos(KataKunci, LowerCase(RawLogs[i])) > 0) then
    begin
      ListBoxLog.Items.Add(RawLogs[i]);
    end;
  end;
end;

// -------------------------------------------------------------------
// 4. PEMROSESAN PYTHON
// -------------------------------------------------------------------
procedure TMainForm.DoProcess;
var
  PyScript: TStringList;
  ConfFloat: Double;
  StrConfValue, StrFPSValue: string;
  FS: TFormatSettings;

  // --- TAMBAHAN VARIABEL UNTUK CEK UKURAN ---
  SR: TSearchRec;
  UkuranMB: Double;

begin


  if VideoPath = '' then
  begin
    ShowMessage('Harap pilih video terlebih dahulu!');
    Exit;
  end;


  // --- BLOK CEK UKURAN VIDEO (MAKSIMAL 100 MB) ---
  if FindFirst(VideoPath, faAnyFile, SR) = 0 then
  begin
    UkuranMB := SR.Size / (1024 * 1024); // Konversi Byte ke Megabyte
    FindClose(SR); // Wajib ditutup untuk mencegah memory leak

    // Jika ukuran lebih dari 100 MB, hentikan eksekusi
    if UkuranMB > 100.0 then
    begin
      ShowMessage(Format('Peringatan: Ukuran video terlalu besar (%.2f MB)!' + sLineBreak +
                         'Batas maksimal yang diizinkan adalah 100 MB.', [UkuranMB]));
      Exit; // Keluar dari prosedur secara paksa (Batal proses)
    end;
  end;

  TulisLog('=== MEMULAI PROSES DETEKSI BARU ===');

  if VlcPlayer1.IsPlay then VlcPlayer1.Stop;
  TulisLog('Video VLC dihentikan.');

  RawLogs.Clear;
  RawMillis.Clear;
  RawSnapshots.Clear;
  ListBoxLog.Clear;
  ImageSnapshot.Picture.Clear;
  BersihkanFolderTemp;
  OutputBuffer := ''; // <--- TAMBAHKAN BARIS INI AGAR BUFFER BERSIH SAAT MULAI

  BtnProses.Enabled := False;
  ProgressBar1.Position := 0;

  PythonEngine1.IO := PythonGUIInputOutput1;
  PythonEngine1.RedirectIO := True;

  // --- MULAI BLOK PERBAIKAN ---
    // Hanya jalankan LoadDll JIKA mesin belum menyala
  if not IsPythonLoaded then
  begin
    PythonEngine1.UseLastKnownVersion := False;
    PythonEngine1.AutoLoad := False;
    PythonEngine1.DllPath := ExtractFilePath(Application.ExeName) + 'python_embed\';
    PythonEngine1.DllName := 'python312.dll';

    TulisLog('Mencoba Load Python DLL: ' + PythonEngine1.DllPath + PythonEngine1.DllName);
    try
      PythonEngine1.LoadDll;
      IsPythonLoaded := True; // Tandai bahwa mesin sudah menyala
      TulisLog('Python DLL BERHASIL dimuat ke memori.');
    except
      on E: Exception do
      begin
        TulisLog('GAGAL Load DLL: ' + E.Message);
        ShowMessage('Gagal memuat Python DLL!' + sLineBreak + E.Message);
        BtnProses.Enabled := True;
        Exit;
      end;
    end;
  end
  else
  begin
    TulisLog('Python DLL sudah aktif, menggunakan instance memori yang ada.');
  end;
    // --- AKHIR BLOK PERBAIKAN ---

  FS := DefaultFormatSettings;
  FS.DecimalSeparator := '.';
  ConfFloat := TrackConf.Position / 100;
  StrConfValue := FloatToStr(ConfFloat, FS);
  StrFPSValue := FloatToStr(SpinFPS.Value, FS);

  PyScript := TStringList.Create;
  try
    TulisLog('Menyusun blok kode Python...');

    PyScript.Add('import sys');
    PyScript.Add('import traceback');
    PyScript.Add('sys.stderr = open(r"' + ExtractFilePath(Application.ExeName) + 'python_error.log", "w")');

    PyScript.Add('try:');
    PyScript.Add('    sys.path.append("' + StringReplace(ExtractFilePath(Application.ExeName), '\', '\\', [rfReplaceAll]) + '")');
    PyScript.Add('    import engine_ai');
    PyScript.Add('    engine_ai.proses_video(');
    PyScript.Add('        r"' + VideoPath + '",');
    PyScript.Add('        ' + StrFPSValue + ',');
    PyScript.Add('        ' + StrConfValue + ',');
    PyScript.Add('        r"' + ExtractFilePath(Application.ExeName) + 'temp_snapshots"');
    PyScript.Add('    )');

    PyScript.Add('except Exception as e:');
    PyScript.Add('    sys.stderr.write("ERROR FATAL DI PYTHON:\n")');
    PyScript.Add('    sys.stderr.write(traceback.format_exc())');
    PyScript.Add('finally:');
    PyScript.Add('    sys.stderr.close()');

    TulisLog('Menyerahkan eksekusi ke PythonEngine...');
    try
      PythonEngine1.ExecStrings(PyScript);
      TulisLog('PythonEngine selesai mengeksekusi script (Kembali ke Lazarus).');
      ShowMessage('Proses Deteksi Selesai!');
      LoadFileTxtKeListBox(ExtractFilePath(Application.ExeName) + 'result.txt' );
      TrdProcess.Terminate;
    except
      on E: Exception do
      begin
        TulisLog('Lazarus Exception saat ExecStrings: ' + E.Message);
        ShowMessage('Terjadi kesalahan skrip: ' + E.Message);
        TrdProcess.Terminate;
      end;
    end;

  finally
    PyScript.Free;
    BtnProses.Enabled := True;
    TulisLog('Prosedur BtnProsesClick selesai dan memori dibebaskan.');

  end;

end;

procedure TMainForm.Button1Click(Sender: TObject);
begin

end;

procedure TMainForm.Button2Click(Sender: TObject);
begin

  ShowMessage(VideoPath);
  // Putar pratinjau di VLC Player
    if VlcPlayer1.IsPlay then VlcPlayer1.Stop;
    // Menggunakan WideString agar path stabil
    VlcPlayer1.VLC.Path := ExtractFilePath(Application.ExeName) + 'vlc_libs\';
    VlcPlayer1.PlayNormal(WideString(VideoPath));
end;

procedure TMainForm.LoadFileTxtKeListBox(const FilePath: string);
var
  SL: TStringList;
begin
  if FileExists(FilePath) then
  begin
    SL := TStringList.Create;
    try
      SL.LoadFromFile(FilePath, TEncoding.UTF8);

      RawLogs.Assign(SL); // <--- KUNCI PERBAIKAN: Simpan ke memori pencarian

      // Tampilkan sesuai dengan isi kotak pencarian saat ini
      if Trim(EditFilter.Text) = '' then
        ListBoxLog.Items.Assign(SL)
      else
        EditFilterChange(Self);
    finally
      SL.Free;
    end;
  end;
end;

// -------------------------------------------------------------------
// 5. MENERIMA DATA DARI PYTHON
// -------------------------------------------------------------------
procedure TMainForm.PythonGUIInputOutput1SendData(Sender: TObject; const Data: string);
var
  Line: string;
  ProgressVal: Double;
  Parts: TStringArray;
  P: Integer;
begin
  // 1. TAMPUNG SEMUA PECAHAN TEKS DARI PYTHON KE DALAM WADAH
  OutputBuffer := OutputBuffer + Data;

  // 2. CEK APAKAH ADA KARAKTER ENTER / BARIS BARU (#10)
  P := Pos(#10, OutputBuffer);

  // 3. JIKA ADA ENTER, BERARTI 1 KALIMAT SUDAH UTUH
  while P > 0 do
  begin
    // Ambil kalimat utuh tersebut
    Line := Copy(OutputBuffer, 1, P - 1);
    // Hapus kalimat tersebut dari wadah antrean
    Delete(OutputBuffer, 1, P);

    // Bersihkan sisa karakter enter/spasi yang tersembunyi
    Line := StringReplace(Line, #13, '', [rfReplaceAll]);
    Line := Trim(Line);

    if Line <> '' then
    begin
      // --- MULAI PENGECEKAN DATA UTUH ---

      // A. Menangkap Update Progress Bar
      if Pos('PROGRESS:', Line) = 1 then
      begin
        Line := StringReplace(Line, 'PROGRESS:', '', [rfReplaceAll]);
        DefaultFormatSettings.DecimalSeparator := '.';
        ProgressVal := StrToFloatDef(Line, 0.0);
        ProgressBar1.Position := Round(ProgressVal);
        Application.ProcessMessages; // Paksa UI update
      end

      // B. Menangkap Data Hasil Deteksi
      else if Pos('DATA|', Line) = 1 then
      begin
        Parts := Line.Split(['|']);
        if Length(Parts) >= 5 then
        begin
          // Simpan ke memori utama
          RawLogs.Add(Parts[2] + ' - ' + Parts[3]);
          RawMillis.Add(Parts[1]);
          RawSnapshots.Add(Parts[4]);

          // Tampilkan ke ListBox jika sesuai filter
          if (EditFilter.Text = '') or (Pos(LowerCase(EditFilter.Text), LowerCase(Parts[2] + ' - ' + Parts[3])) > 0) then
          begin
            ListBoxLog.Items.Add(Parts[2] + ' - ' + Parts[3]);
            ListBoxLog.TopIndex := ListBoxLog.Items.Count - 1; // Auto-scroll
          end;
        end;
        Application.ProcessMessages;
      end

      // C. Pesan Log / Error Biasa
      else
      begin
        RawLogs.Add(Line);
        RawMillis.Add('');
        RawSnapshots.Add('');
        ListBoxLog.Items.Add(Line);
        ListBoxLog.TopIndex := ListBoxLog.Items.Count - 1; // Auto-scroll
        Application.ProcessMessages;
      end;
    end;

    // Cek lagi, barangkali ada sisa kalimat utuh lain di dalam wadah
    P := Pos(#10, OutputBuffer);
  end;
end;

procedure TMainForm.spVLCPauseClick(Sender: TObject);
begin
  VlcPlayer1.Pause();
end;

procedure TMainForm.spVLCPlayClick(Sender: TObject);
begin
  VlcPlayer1.Play(VideoPath);
end;

procedure TMainForm.spVLCSetopClick(Sender: TObject);
begin
  VlcPlayer1.Stop(1000);
end;

procedure TMainForm.tmPlaySnapshotTimer(Sender: TObject);
var
  SelText, TimeStr, ImgPath: string;
  Parts: TStringArray;
  Minutes, TargetMs: Int64;
  Seconds: Double;
  FS: TFormatSettings;
begin

  if stop = true then exit;
  if i = ListBoxLog.Count-1 then exit;

  inc(i);
  SelText := ListBoxLog.Items[i];
  ListBoxLog.ItemIndex:=i;
  // 2. Pisahkan berdasarkan pemisah " - " untuk mengambil bagian waktunya saja
  Parts := SelText.Split([' - ']);
  if Length(Parts) < 2 then Exit;

  TimeStr := Trim(Parts[0]);

  // 3. Konversi format "MM:SS.ff" menjadi Milidetik
  FS := DefaultFormatSettings;
  FS.DecimalSeparator := '.';

  Parts := TimeStr.Split([':']);
  if Length(Parts) = 2 then
  begin
    Minutes := StrToIntDef(Parts[0], 0);
    Seconds := StrToFloatDef(StringReplace(Parts[1], ',', '.', [rfReplaceAll]), 0.0, FS);
    TargetMs := Round((Minutes * 60 + Seconds) * 1000);
  end
  else
    TargetMs := 0;

  MiliDetik:= TargetMs;

  // 4. Cari file Snapshot berdasarkan milidetik
  ImgPath := ExtractFilePath(Application.ExeName) + 'temp_snapshots\snap_' + IntToStr(TargetMs) + '.jpg';

  // 5. Tampilkan Barang Bukti (Snapshot) jika ada
  if FileExists(ImgPath) then
    ImageSnapshot.Picture.LoadFromFile(ImgPath)
  else
    ImageSnapshot.Picture.Clear;


end;

procedure TMainForm.tmProgressTimer(Sender: TObject);
var
  FilePath: string;
  Stream: TFileStream;
  SL: TStringList;
begin
  inc(i);
  dtgauge.Position:=i;


  if i = 100 then
    begin
      i := 0 ;
      dtgauge.Position:=0;
    end;

  if i mod 5 = 0 then
  begin

  FilePath := ExtractFilePath(Application.ExeName) + 'result.txt';

  // Pastikan file benar-benar ada sebelum dibaca
  if not FileExists(FilePath) then Exit;

  SL := TStringList.Create;
  try
    try
      // fmShareDenyNone adalah kunci agar tidak error walau file sedang ditulis Python
      Stream := TFileStream.Create(FilePath, fmOpenRead or fmShareDenyNone);
      try
        SL.LoadFromStream(Stream, TEncoding.UTF8);
      finally
        Stream.Free;
      end;

      // Cegah kedipan (flicker) pada UI saat ListBox diperbarui
      ListBoxLog.Items.BeginUpdate;
      try
        // Hanya update jika jumlah baris bertambah untuk menghemat memori
        if ListBoxLog.Items.Count <> SL.Count then
        begin
          ListBoxLog.Items.Assign(SL);
          ListBoxLog.TopIndex := ListBoxLog.Items.Count - 1; // Auto-scroll ke bawah
        end;
      finally
        ListBoxLog.Items.EndUpdate;
      end;

    except
      // Blok pelindung: Jika file sedang di-lock secara mutlak oleh sistem pada milidetik itu,
      // abaikan error sementara, timer akan mencoba lagi pada siklus berikutnya (1 detik kemudian).
    end;
  finally
    SL.Free;
  end;

  end;
end;

// -------------------------------------------------------------------
// 6. FITUR AUDIT / DOUBLE-CLICK (VLC LOMPAT WAKTU + TAMPIL GAMBAR)
// -------------------------------------------------------------------
procedure TMainForm.ListBoxLogDblClick(Sender: TObject);
var
  SelText, TimeStr, ImgPath: string;
  Parts: TStringArray;
  Minutes, TargetMs: Int64;
  Seconds: Double;
  FS: TFormatSettings;
begin

  tbsImage.show;
  if ListBoxLog.ItemIndex = -1 then Exit;

  // 1. Ambil teks baris yang diklik (Contoh: "00:06.00 - car, car, car")
  SelText := ListBoxLog.Items[ListBoxLog.ItemIndex];
  i := ListBoxLog.ItemIndex;
  // 2. Pisahkan berdasarkan pemisah " - " untuk mengambil bagian waktunya saja
  Parts := SelText.Split([' - ']);
  if Length(Parts) < 2 then Exit;

  TimeStr := Trim(Parts[0]);

  // 3. Konversi format "MM:SS.ff" menjadi Milidetik
  FS := DefaultFormatSettings;
  FS.DecimalSeparator := '.';

  Parts := TimeStr.Split([':']);
  if Length(Parts) = 2 then
  begin
    Minutes := StrToIntDef(Parts[0], 0);
    Seconds := StrToFloatDef(StringReplace(Parts[1], ',', '.', [rfReplaceAll]), 0.0, FS);
    TargetMs := Round((Minutes * 60 + Seconds) * 1000);
  end
  else
    TargetMs := 0;

  MiliDetik:= TargetMs;
  // 4. Cari file Snapshot berdasarkan milidetik
  ImgPath := ExtractFilePath(Application.ExeName) + 'temp_snapshots\snap_' + IntToStr(TargetMs) + '.jpg';

  // 5. Tampilkan Barang Bukti (Snapshot) jika ada
  if FileExists(ImgPath) then
    ImageSnapshot.Picture.LoadFromFile(ImgPath)
  else
    ImageSnapshot.Picture.Clear;

  // 6. Perintah VLC Lompat Waktu
  if tbsVideo.Showing then
  begin
  if VideoPath <> '' then
  begin
    VlcPlayer1.stop;
    if not VlcPlayer1.IsPlay then
    begin
      VlcPlayer1.Play(WideString(VideoPath));
      VlcPlayer1.SetVideoPosInMs(TargetMs);
      VlcPlayer1.stop;
    end;
  end;

  end
  else
  VlcPlayer1.stop;

end;

procedure TMainForm.MenuItem1Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TMainForm.TulisLog(const Pesan: string);
var
  LogFile: TextFile;
  NamaFile: string;
begin
  NamaFile := ExtractFilePath(Application.ExeName) + 'crash_debug.txt';
  AssignFile(LogFile, NamaFile);
  if FileExists(NamaFile) then Append(LogFile) else Rewrite(LogFile);
  Writeln(LogFile, FormatDateTime('hh:nn:ss.zzz', Now) + ' -> ' + Pesan);
  CloseFile(LogFile);
end;

end.
