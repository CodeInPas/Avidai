unit player_form;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  PasLibVlcPlayerUnit;

type

  { TPlayerForm }

  TPlayerForm = class(TForm)
    tmplay: TTimer;
    VlcPlayer1: TPasLibVlcPlayer;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
     IsSeeking: Boolean; // <--- TAMBAHKAN BARIS INI
  public
    VideoFile: string;
    procedure PlayMe(VideoPath:string;TargetMs:Int64);

  end;

var
  PlayerForm: TPlayerForm;

implementation

{$R *.lfm}

{ TPlayerForm }

procedure TPlayerForm.FormCreate(Sender: TObject);
begin
    VlcPlayer1.VLC.Path := ExtractFilePath(Application.ExeName) + 'vlc_libs\';
end;



procedure TPlayerForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  VlcPlayer1.Stop(1000);
end;

procedure TPlayerForm.PlayMe(VideoPath:string;TargetMs:Int64);
begin

if VideoPath <> '' then
  begin
    VlcPlayer1.stop;
    if not VlcPlayer1.IsPlay then
    begin
      VlcPlayer1.Play(WideString(VideoPath));
      VlcPlayer1.SetVideoPosInMs(TargetMs);
      Sleep(1000);
      VlcPlayer1.Pause();
    end;
  end;


end;

end.

