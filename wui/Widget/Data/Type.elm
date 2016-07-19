module Widget.Data.Type exposing (..)

import List
import String exposing (contains)

{---------------------------------------}
type alias Id = String

type alias Record =
  { id       : Id
  , label    : String
  , descr    : String
  , value    : Value
  , fmtr     : Formatter
--  , kids     : Kids
  }


type alias Node =
  { rec  : Record
  , kids : Tree
  }

type Tree = Kids (List Node)

type Value
  = BoolValue Bool
  | StringValue String
  | RootCmd
  -- | Group Bool
  | Group Orientation
  | Switch Id


type Orientation
  = Vertical
  | Horizontal
  | Disoriented        -- Diagonal   -- NO OP


type Formatter
  = BoolFmtr String String
  | StringFmtr String
  | KidsListFmtr String String
--  | KidsByIdFmtr String String
  | SelectedKidFmtr


getKids : Node -> List Node
getKids node =
  case node.kids of
    Kids kids_l -> kids_l
kidsOf : Node -> List Node
kidsOf = getKids

replaceKids : Node -> List Node -> Node
replaceKids node newKids_l =
  { node | kids = Kids newKids_l }

insertKid : Node -> Node -> Node
insertKid newKid node =
  --{ node | kids = Kids ( newKid :: (kidsOf node) ) }
  replaceKids node <| newKid :: (kidsOf node)


  {-- id       : Id
  , label    : String
  , descr    : String
  , value    : Value
  , fmtr     : Formatter
--  , kids     : Kids
  --}
notFoundRec : String -> Record
notFoundRec errMsg =
  ( aBool "id" errMsg errMsg errMsg ).rec

notFoundNode : String -> Node
notFoundNode errMsg =
  Node (notFoundRec errMsg) (Kids [])

fmtList : String -> String -> Formatter
fmtList cmdFmt listSep =
  KidsListFmtr cmdFmt listSep

aRoot : String -> List Node -> Formatter -> Node
aRoot label kids_l fmtr =
    Node
      ( Record "root" label "root node of the command" RootCmd fmtr )
      ( Kids kids_l )

aVertical : String -> String -> List Node -> Formatter -> Node
aVertical id label kids_l fmtr =
  Node
    ( Record (id ++ "-VG") label "a vertical grouping" (Group Vertical) fmtr )
    ( Kids kids_l )

aHorizontal : String -> String -> List Node -> Formatter -> Node
aHorizontal id label kids_l fmtr =
  Node
    ( Record (id ++ "-HG") label "a horizontal grouping" (Group Horizontal) fmtr )
    ( Kids kids_l )

aSwitch : String -> String -> List Node -> Node
aSwitch id label kids_l =
  let
    optFirstKid = List.head kids_l
    fkid =
      case optFirstKid of
        Nothing  -> ""
        Just kid -> kid.rec.id
  in
    Node
      ( Record (id ++ "-SW") label "a switch" (Switch fkid) SelectedKidFmtr )
      ( Kids kids_l )

aBoolX : Id -> String -> String -> Bool -> String -> String -> Node
aBoolX id label descr flag cmdTrue cmdFalse =
  Node
    ( Record (id ++ "_B") label descr (BoolValue flag) (BoolFmtr cmdTrue cmdFalse) )
    ( Kids [] )

aBool : Id -> String -> String -> String -> Node
aBool id label descr cmdTrue =
  aBoolX (id ++ "F") label descr False cmdTrue ""
  --Node
    --( Record (id ++ "_B") label descr (BoolValue False) (BoolFmtr cmdTrue "") )
    --( Kids [] )

aBooT : Id -> String -> String -> String -> Node
aBooT id label descr cmdTrue =
  aBoolX (id ++ "T") label descr True cmdTrue ""

aString : Id -> String -> String -> String -> Node
aString id label descr cmdFmt =
  let
    strValue = StringValue (validateFormatForParam cmdFmt)
  in
    Node
      ( Record (id ++ "_S") label descr strValue (StringFmtr cmdFmt) )
      ( Kids [] )

validateFormatForParam : String -> String
validateFormatForParam cmdFmt =
      if contains "{{}}" cmdFmt then
        ""
      else
        "!! format MUST contain '{{}}' !!"
