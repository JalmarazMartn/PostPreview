codeunit 69000 "TIP IIEE Post Preview"
{
    SingleInstance = true;

    var
        TempExciseTaxEntry: Record "TIP Excise Tax Entry" temporary;
        IsPreview: Boolean;

    [EventSubscriber(ObjectType::Table, Database::"TIP Excise Tax Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertExciseTax(var Rec: Record "TIP Excise Tax Entry")
    begin
        if not IsPreview then
            exit;
        if rec.IsTemporary() then
            exit;
        TempExciseTaxEntry := Rec;
        if TempExciseTaxEntry.Insert() then;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnAfterBindSubscription', '', false, false)]
    local procedure ActivePreview(var PostingPreviewEventHandler: Codeunit "Posting Preview Event Handler")
    begin
        IsPreview := true;
        TempExciseTaxEntry.Reset();
        TempExciseTaxEntry.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnAfterUnbindSubscription', '', false, false)]
    local procedure DeActivePreview()
    begin
        IsPreview := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Preview Event Handler", 'OnAfterFillDocumentEntry', '', false, false)]
    local procedure ShowAllEntries(var DocumentEntry: Record "Document Entry" temporary)
    var
        PostingPreviewEventHandler: Codeunit "Posting Preview Event Handler";
    begin
        if not TempExciseTaxEntry.IsEmpty then
            PostingPreviewEventHandler.InsertDocumentEntry(TempExciseTaxEntry, DocumentEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Preview Event Handler", 'OnAfterShowEntries', '', false, false)]
    local procedure ShowIIEEEntries(TableNo: Integer)
    var
    begin
        if TableNo <> Database::"TIP Excise Tax Entry" then
            exit;
        Page.Run(Page::"TIP Excise Tax Entries", TempExciseTaxEntry);
    end;
}