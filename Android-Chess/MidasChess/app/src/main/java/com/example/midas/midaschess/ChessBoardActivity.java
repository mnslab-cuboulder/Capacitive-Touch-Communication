package com.example.midas.midaschess;

import android.graphics.Color;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

public class ChessBoardActivity extends AppCompatActivity {

    //private TextView bitText;

    //pressTime is current time when pressed, releaseTime is current time when released
    private long pressTime = -1l;
    private long releaseTime = 1l;

    //duration is time elapsed pressed, duration2 is time elapsed lifted
    private long duration1,duration0= -1l;

    private String idString = "";

    String decode = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_chess_board);

        //bitText = (TextView)findViewById(R.id.bstream_id);

        DisplayMetrics displayMetrics = new DisplayMetrics();
        getWindowManager().getDefaultDisplay().getMetrics(displayMetrics);
        int scrHeight = displayMetrics.heightPixels;
        RelativeLayout wholeBoard = (RelativeLayout)findViewById(R.id.wholeBoard);
        for(int i=0;i<wholeBoard.getChildCount();i++) {
            wholeBoard.getChildAt(i).setMinimumHeight(scrHeight / 8);
        }
        setGridFuncs();
        }

    void setGridFuncs()
    {
        RelativeLayout wholeBoard = (RelativeLayout)findViewById(R.id.wholeBoard);
        for(int i=0;i<wholeBoard.getChildCount();i++) {
            LinearLayout row = (LinearLayout) wholeBoard.getChildAt(i);
            for(int x=0;x<row.getChildCount();x++)
            {
                final Button tile = (Button) row.getChildAt(x);
                final int tileCol = x;
                final int tileRow = i;
                tile.setOnTouchListener(new View.OnTouchListener() {
                    @Override
                    public boolean onTouch(View v, MotionEvent event) {

                        if(idString.length() == 4){
                            resetAll();
                            String king = "|100";
                            String rook = "|011";
                            String knight = "|010";
                            String queen = "|001";
                            String bishop = "|101";
                            if(idString.equals(rook)){
                                rookAt(tileRow,tileCol);
                            }
                            else if(idString.equals(king)){
                                kingAt(tileRow,tileCol);
                            }
                            else if(idString.equals(knight)){
                                knightAt(tileRow,tileCol);
                            }
                            else if(idString.equals(queen)){
                                queenAt(tileRow,tileCol);
                            }
                            else if(idString.equals(bishop)){
                                bishopAt(tileRow,tileCol);
                            }
                            else{
                                resetAll();
                            }
                            //idString = "";
                        }
                        else if(idString.length() > 4){
                            //idString = "";
                        }

                        if(event.getAction()==MotionEvent.ACTION_DOWN)
                        {
                            onDown();
                            //send API down event
                            //i.e.: sendApi(event);
                        }
                        else if(event.getAction()==MotionEvent.ACTION_UP)
                        {
                            onUp();
                            //send API up event
                            //get API current state
                            //update board with current state
                            /*
                            FOR EXAMPLE:
                            string pattern[] = {"|000|",
                                                "|001|",
                                                "|010|"};
                            KNIGHT=1;
                            KING=2;
                            oldBoardState=newBoardState;
                            sendApi(event);
                            newBoardState=0;
                            for(int i=0;i<pattern.size();i++)
                            {
                                if(apiIdentification(pattern[i]))
                                {
                                    newBoardState=i;
                                    break;
                                }
                            }
                            if(oldBoardState!=newBoardState)
                            {
                                switch(oldBoardState)
                                {
                                case KNIGHT:
                                    removeKnightAt(tileRow,tileCol);
                                    break;
                                case KING:
                                    removeKingAt(tileRow,tileCol);
                                    break;
                                }
                                switch(newBoardState)
                                {
                                case KNIGHT:
                                    knightAt(tileRow,tileCol);
                                    break;
                                case KING:
                                    kingAt(tileRow,tileCol);
                                    break;
                                }
                            }
                             */
                        }
                        return true;
                    }
                });
            }
        }
    }

    void onDown(){
        pressTime = System.currentTimeMillis(); //taking in time
        if(releaseTime != 1l){
            duration0 = System.currentTimeMillis() - releaseTime;   //calc duration lifted
            if(duration0 > 400) //Remove long waits
                idString = "";

            //time += (" U " + String.valueOf(duration0));    //print out time up
            //timeUpText.setText(time);

            String s = String.valueOf(duration0/100);
            int z = Integer.valueOf(s);

            if(duration0 > 75 && duration0 < 180){
                idString += "0";
            }
            if(duration0 > 180 && duration0 < 300){
                idString += "00";
            }
        }
        //bitText.setText(idString);

    }

    void onUp(){
        releaseTime = System.currentTimeMillis();
        duration1 = System.currentTimeMillis() - pressTime;
        //time += (" D " + String.valueOf(duration1));
        //timeUpText.setText(time);
        //timeDownText.setText(String.valueOf(duration1));
        if(duration1 > 0 && duration1 < 75){
            idString += "1";
        }
        if(duration1 > 75 && duration1 < 125){
            idString = "|";
        }

        //bitText.setText(idString);
    }

    void knightAt(int row, int col)
    {
        highlightTile(row - 1, col - 2);
        highlightTile(row - 2, col - 1);
        highlightTile(row - 1, col + 2);
        highlightTile(row - 2, col + 1);
        highlightTile(row + 1, col - 2);
        highlightTile(row + 2, col - 1);
        highlightTile(row + 1, col + 2);
        highlightTile(row + 2, col + 1);
        selectedTile(row,col);
    }

    void removeKnightAt(int row, int col)
    {
        resetTile(row - 1, col - 2);
        resetTile(row - 2, col - 1);
        resetTile(row - 1, col + 2);
        resetTile(row - 2, col + 1);
        resetTile(row + 1, col - 2);
        resetTile(row + 2, col - 1);
        resetTile(row + 1, col + 2);
        resetTile(row + 2, col + 1);
    }

    void kingAt(int row, int col)
    {
        highlightTile(row - 1, col);
        highlightTile(row + 1, col);
        highlightTile(row, col - 1);
        highlightTile(row, col + 1);
        highlightTile(row - 1, col - 1);
        highlightTile(row + 1, col + 1);
        highlightTile(row + 1, col - 1);
        highlightTile(row - 1, col + 1);
        selectedTile(row,col);
    }

    void removeKingAt(int row, int col)
    {
        resetTile(row - 1, col);
        resetTile(row + 1, col);
        resetTile(row, col - 1);
        resetTile(row, col + 1);
        resetTile(row - 1, col - 1);
        resetTile(row + 1, col + 1);
        resetTile(row + 1, col - 1);
        resetTile(row - 1, col + 1);
    }

    void queenAt(int row, int col)
    {
        for(int i=-8;i<=8;i++)
        {
            highlightTile(row+i,col+i);
            highlightTile(row+i,col-i);
            highlightTile(row,col+i);
            highlightTile(row+i,col);
        }
        selectedTile(row,col);
    }

    void removeQueenAt(int row, int col)
    {
        for(int i=-8;i<=8;i++)
        {
            resetTile(row + i, col + i);
            resetTile(row + i, col - i);
            resetTile(row, col + i);
            resetTile(row + i, col);
        }
    }

    void bishopAt(int row, int col)
    {
        for(int i=-8;i<=8;i++)
        {
            highlightTile(row + i, col + i);
            highlightTile(row + i, col - i);
        }
        selectedTile(row,col);
    }

    void removeBishopAt(int row, int col)
    {
        for(int i=-8;i<=8;i++)
        {
            resetTile(row + i, col + i);
            resetTile(row+i,col-i);
        }
    }

    void rookAt(int row, int col)
    {
        for(int i=-8;i<=8;i++)
        {
            highlightTile(row + i, col);
            highlightTile(row, col + i);
        }
        selectedTile(row,col);
    }

    void removeRookAt(int row, int col)
    {
        for(int i=-8;i<=8;i++)
        {
            resetTile(row + i, col);
            resetTile(row, col + i);
        }
    }

    void resetTile(int row, int col)
    {
        if(row<0 || row>7 || col<0 || col>7)return;
        RelativeLayout wholeBoard = (RelativeLayout)findViewById(R.id.wholeBoard);
        int val=0;
        if((row+col)%2==0)val=255;
        ((Button)((LinearLayout) wholeBoard.getChildAt(row)).getChildAt(col)).setBackgroundColor(Color.rgb(val,val,val));
    }

    void highlightTile(int row, int col)
    {
        if(row<0 || row>7 || col<0 || col>7)return;
        RelativeLayout wholeBoard = (RelativeLayout)findViewById(R.id.wholeBoard);
        int val=0;
        if((row+col)%2==0)val=100;
        ((Button)((LinearLayout) wholeBoard.getChildAt(row)).getChildAt(col)).setBackgroundColor(Color.rgb(val,155+val,val));
    }

    void selectedTile(int row, int col){
        if(row<0 || row>7 || col<0 || col>7)return;
        RelativeLayout wholeBoard = (RelativeLayout)findViewById(R.id.wholeBoard);
        int val=0;
        if((row+col)%2==0)val=100;
        ((Button)((LinearLayout) wholeBoard.getChildAt(row)).getChildAt(col)).setBackgroundColor(Color.rgb(155+val,155+val,155+val));
    }

    void resetAll(){
        for(int x = 0; x < 9; x++){
            for(int y = 0; y < 9; y++)
                resetTile(x,y);
        }
    }
}
