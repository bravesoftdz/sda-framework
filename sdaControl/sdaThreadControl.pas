unit sdaThreadControl;

interface

{$INCLUDE 'sda.inc'}

uses
  sdaWindows;

type
  TSdaThreadControl = record
  private
    FHandle: THandle;
    function GetExitCode: DWORD;
    function GetTerminated: Boolean;
    function GetID: UINT;
    procedure SetID(const Value: UINT);
  public
    property Handle: THandle read FHandle write FHandle;
    property ID: UINT read GetID write SetID;
    procedure DestroyHandle;

    property ExitCode: DWORD read GetExitCode;
    property Terminated: Boolean read GetTerminated;

    procedure Suspend;
    procedure Resume;
    procedure Terminate(ExitCode: DWORD);
    procedure SetAffinity(Mask: DWORD);

    procedure PostMessage(Msg: UINT; wParam: WPARAM; lParam: LPARAM);
  end;

  TSdaCurrentThread = record
  private
    function GetHandle: THandle;
    function GetID: UINT;
  public
    property ID: UINT read GetID;
    property Handle: THandle read GetHandle;
  end;

threadvar
  Thread: TSdaCurrentThread;

implementation

{ TSdaThreadControl }

procedure TSdaThreadControl.DestroyHandle;
begin
  CloseHandle(Handle);
  FHandle := 0;
end;

function TSdaThreadControl.GetExitCode: DWORD;
begin
  if Handle <> 0 then GetExitCodeThread(Handle, Result)
    else Result := DWORD(-1);
end;

function TSdaThreadControl.GetID: UINT;
begin
  Result := GetThreadId(Handle);
end;

function TSdaThreadControl.GetTerminated: Boolean;
var
  code: DWORD;
begin
  if Handle <> 0 then
  begin
    GetExitCodeThread(Handle, code);
    Result := code = STILL_ACTIVE;
  end else Result := true;
end;

procedure TSdaThreadControl.PostMessage(Msg: UINT; wParam: WPARAM;
  lParam: LPARAM);
begin
  if Handle <> 0 then
    PostThreadMessage(GetThreadId(Handle), Msg, wParam, lParam);
end;

procedure TSdaThreadControl.Resume;
begin
  if Handle <> 0 then ResumeThread(Handle);
end;

procedure TSdaThreadControl.SetAffinity(Mask: DWORD);
begin
  if Handle <> 0 then SetThreadAffinityMask(Handle, Mask);
end;

procedure TSdaThreadControl.SetID(const Value: UINT);
begin
  FHandle := OpenThread(THREAD_SUSPEND_RESUME or THREAD_TERMINATE or
    THREAD_SET_LIMITED_INFORMATION or THREAD_QUERY_LIMITED_INFORMATION,
    false, Value);
end;

procedure TSdaThreadControl.Suspend;
begin
  if Handle <> 0 then SuspendThread(Handle);
end;

procedure TSdaThreadControl.Terminate(ExitCode: DWORD);
begin
  if Handle <> 0 then TerminateThread(Handle, ExitCode);
end;

{ TSdaCurrentThread }

function TSdaCurrentThread.GetHandle: THandle;
begin
  Result := GetCurrentThread;
end;

function TSdaCurrentThread.GetID: UINT;
begin
  Result := GetCurrentThreadId;
end;

end.
